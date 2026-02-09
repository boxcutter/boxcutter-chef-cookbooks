module Boxcutter
  class OnePassword
    # https://releases.1password.com/developers/cli/
    OP_CLI_VERSION = '2.32.1'.freeze
    OP_CLI_DOWNLOAD_URL_AMD64 = "https://cache.agilebits.com/dist/1P/op2/pkg/v#{OP_CLI_VERSION}/op_linux_amd64_v#{OP_CLI_VERSION}.zip".freeze
    OP_CLI_DOWNLOAD_URL_ARM64 = "https://cache.agilebits.com/dist/1P/op2/pkg/v#{OP_CLI_VERSION}/op_linux_arm64_v#{OP_CLI_VERSION}.zip".freeze
    STDIO_TRUNCATE = 2000

    def self.op_whoami(type = 'auto')
      cli = op_cli
      env = op_environment(type)

      command = "#{cli} whoami"
      run_shellout(command, :env => env, :event => 'op_whoami', :log_stdout => true).stdout.strip
    end

    def self.op_read(reference, type = 'auto')
      env = op_environment(type)
      cli = op_cli

      # 1Password Connect Server does not support `op user get --me`
      if ['auto', 'service_account'].include?(type)
        command = "#{cli} user get --me"
        run_shellout(command, :env => env, :event => 'op_user_get_me', :log_stdout => true)
      else
        Chef::Log.debug(
          "boxcutter_onepassword[op_read]: skipping `op user get --me` for (connect_server)",
        )
      end

      command = "#{cli} read '#{reference}'"
      # IMPORTANT: Do not log stdout (secret contents)
      run_shellout(
        command,
        :env => env,
        :event => 'op_read',
        :extra => { :reference => reference },
        :log_stdout => false,
      ).stdout.strip
    end

    def self.op_document_get(item, vault, type = 'auto')
      env = op_environment(type)

      op_document_cmd = [op_cli, 'document', 'get', "'#{item}'"]
      op_document_cmd << "--vault '#{vault}'" unless vault.nil?
      command = op_document_cmd.join(' ')

      # Documents may be secrets too; default: no stdout logging.
      run_shellout(
        command,
        :env => env,
        :event => 'op_document_get',
        :extra => { :item => item, :vault => vault },
        :log_stdout => false,
      ).stdout.strip
    end

    def self.op_environment(type)
      # Determine which auth mode we'll use, and log clearly (without secrets).
      requested = type

      if op_connect_server_token_found? && ['auto', 'connect_server'].include?(requested)
        chosen = 'connect_server'
        env = {
          # FIX: OP_CONNECT_HOST should come from OP_CONNECT_HOST
          'OP_CONNECT_HOST'  => token_from_env_or_file('OP_CONNECT_HOST',  op_connect_host_path),
          'OP_CONNECT_TOKEN' => token_from_env_or_file('OP_CONNECT_TOKEN', op_connect_token_path),
        }

        Chef::Log.info(
          "boxcutter_onepassword[op_environment]: using auth=#{chosen} requested=#{requested.inspect} " \
          "env_keys=#{env.keys.sort.inspect} sources=#{summarize_token_sources(env)}",
        )
        return env
      end

      if op_service_account_token_found? && ['auto', 'service_account'].include?(requested)
        chosen = 'service_account'
        env = {
          'OP_SERVICE_ACCOUNT_TOKEN' => token_from_env_or_file(
            'OP_SERVICE_ACCOUNT_TOKEN',
            op_service_account_token_path,
          ),
        }

        Chef::Log.info(
          "boxcutter_onepassword[op_environment]: using auth=#{chosen} requested=#{requested.inspect} " \
            "env_keys=#{env.keys.sort.inspect} sources=#{summarize_token_sources(env)}",
        )
        return env
      end

      Chef::Log.error(
        "boxcutter_onepassword[op_environment]: no usable auth found requested=#{requested.inspect} " \
        "connect_server_present=#{op_connect_server_token_found?} " \
        "service_account_present=#{op_service_account_token_found?}",
      )
      fail "boxcutter_onepassword[op_environment]: 1Password token not found (type=#{requested.inspect})"
    end

    # ---- CLI selection / bootstrap ----

    # If we are called during compile time, we may need to bootstrap the
    # cli. We store it under /opt so it won't conflict with the final
    # package insta..
    def self.bootstrap_op_cli
      '/opt/op-bootstrap/bin/op'
    end

    def self.op_cli
      unless ::File.exist?('/usr/bin/op')
        Chef::Log.warn('boxcutter_onepassword[op_cli]: /usr/bin/op not found; bootstrapping op cli at compile time')
        install_bootstrap_op_cli
        return bootstrap_op_cli
      end

      '/usr/bin/op'
    end

    # If "op_read" is called during compile time, this might happen before
    # the main default recipe runs to install the cli. Bootstrap the 1Password
    # cli at compile time to ensure things don't fail at this point.
    def self.install_bootstrap_op_cli
      require 'rbconfig'
      require 'net/http'
      require 'uri'
      require 'zip'

      architecture = RbConfig::CONFIG['host_cpu']

      # https://releases.1password.com/developers/cli/
      url = OP_CLI_DOWNLOAD_URL_AMD64
      if ['aarch64', 'arm64'].include?(architecture)
        url = OP_CLI_DOWNLOAD_URL_ARM64
      end
      tmp_path = ::File.join(Chef::Config[:file_cache_path], ::File.basename(url))

      uri = URI.parse(url)

      Chef::Log.info(
        'boxcutter_onepassword[install_bootstrap_op_cli]: downloading op cli ' \
        "arch=#{architecture} to #{tmp_path} (basename=#{::File.basename(url)})",
      )

      # Open a connection and download the file
      Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new(uri)
        http.request(request) do |response|
          if response.code.to_i >= 400
            fail 'boxcutter_onepassword[install_bootstrap_op_cli]: failed download ' \
                 "http=#{response.code} url_basename=#{::File.basename(url)}"
          end

          # Write the file to disk
          ::File.open(tmp_path, 'wb') do |file|
            response.read_body do |chunk|
              file.write(chunk)
            end
          end
        end
      end

      bootstrap_op_cli_dirname = ::File.dirname(bootstrap_op_cli)
      FileUtils.mkdir_p(bootstrap_op_cli_dirname) unless Dir.exist?(bootstrap_op_cli_dirname)
      unzip_file(tmp_path, 'op', bootstrap_op_cli_dirname)
      op_path = ::File.join(bootstrap_op_cli_dirname, 'op')
      ::File.chmod(0o755, op_path)

      Chef::Log.info("boxcutter_onepassword[install_bootstrap_op_cli]: installed bootstrap op cli at #{op_path}")
    end

    def self.unzip_file(zip_file, filename, destination)
      Chef::Log.debug(
        "boxcutter_onepassword[unzip_file]: extracting #{filename.inspect} from #{zip_file} to #{destination}",
      )

      Zip::File.open(zip_file) do |zip|
        entry = zip.find_entry(filename)
        fail "boxcutter_onepassword[unzip_file]: file #{filename.inspect} not found in archive #{zip_file}" unless entry

        target_path = ::File.join(destination, entry.name)
        # Skip extraction if file already exists
        if ::File.exist?(target_path)
          Chef::Log.debug("boxcutter_onepassword[unzip_file]: #{target_path} exists; skipping extraction")
        else
          ::FileUtils.mkdir_p(File.dirname(target_path))
          entry.extract(target_path)
          Chef::Log.debug("boxcutter_onepassword[unzip_file]: extracted #{filename.inspect} to #{destination}")
        end
      end
    end

    # ---- token discovery helpers ----

    def self.op_connect_host_path
      op_connect_host_path = '/etc/cinc/op_connect_host'
      unless ::File.exist?(op_connect_host_path)
        op_connect_host_path = '/etc/chef/op_connect_host'
      end
      Chef::Log.debug("boxcutter_onepassword: using #{op_connect_host_path} for op_connect_host_path")
      op_connect_host_path
    end

    def self.op_connect_token_path
      op_connect_token_path = '/etc/cinc/op_connect_token'
      unless ::File.exist?(op_connect_token_path)
        op_connect_token_path = '/etc/chef/op_connect_token'
      end
      Chef::Log.debug("boxcutter_onepassword: using #{op_connect_token_path} for op_connect_token_path")
      op_connect_token_path
    end

    def self.op_connect_server_token_found?
      Chef::Log.debug('boxcutter_onepassword: probing for 1Password connect server token')
      if ENV['OP_CONNECT_HOST'] && ENV['OP_CONNECT_TOKEN']
        Chef::Log.debug('boxcutter_onepassword: OP_CONNECT_HOST and OP_CONNECT_TOKEN environment variables found!')
        return true
      end

      if ::File.exist?(op_connect_host_path) && ::File.exist?(op_connect_token_path)
        Chef::Log.debug("boxcutter_onepassword: #{op_connect_host_path} and #{op_connect_token_path} files found!")
        return true
      end

      Chef::Log.debug('boxcutter_onepassword: 1Password connect server token NOT found')
      return false
    end

    def self.op_service_account_token_path
      op_service_account_token_path = '/etc/cinc/op_service_account_token'
      unless ::File.exist?(op_service_account_token_path)
        op_service_account_token_path = '/etc/chef/op_service_account_token'
      end
      Chef::Log.debug(
        "boxcutter_onepassword: using #{op_service_account_token_path} for op_service_account_token_path",
      )
      op_service_account_token_path
    end

    def self.op_service_account_token_found?
      Chef::Log.debug('boxcutter_onepassword: probing for service_account auth (OP_SERVICE_ACCOUNT_TOKEN)')

      if ENV['OP_SERVICE_ACCOUNT_TOKEN']
        Chef::Log.debug('boxcutter_onepassword: OP_SERVICE_ACCOUNT_TOKEN environment variable found!')
        return true
      end

      if ::File.exist?(op_service_account_token_path)
        Chef::Log.debug("boxcutter_onepassword: service_account file present (#{op_service_account_token_path})")
        return true
      end

      Chef::Log.debug('boxcutter_onepassword: 1Password Service Account token NOT found')
      return false
    end

    def self.token_from_env_or_file(environment_variable_name, file_path)
      if ENV[environment_variable_name]
        Chef::Log.debug('boxcutter_onepassword[token_from_env_or_file]: Using 1Password ' +
                        "token found in #{environment_variable_name} environment variable")
        return ENV[environment_variable_name]
      end

      if File.exist?(file_path)
        token = ::File.read(file_path).strip
        fail "boxcutter_onepassword[token_from_env_or_file]: #{file_path} empty" if token.empty?
        Chef::Log.debug("boxcutter_onepassword[token_from_env_or_file]: using token from file #{file_path}")
        return token
      end

      fail 'boxcutter_onepassword[op_service_account_token]: token not found in ' \
           "env #{environment_variable_name} or file #{file_path}"
    end

    # ---- logging/shellout helpers ----

    def self.run_shellout(command, env:, event:, extra: {}, log_stdout: false)
      Chef::Log.debug(
        "boxcutter_onepassword[#{event}]: " \
        "command=#{command.inspect} env_keys=#{(env || {}).keys.sort.inspect} extra=#{extra.inspect}",
      )

      shellout = Mixlib::ShellOut.new(command, :env => env)
      shellout.run_command

      if shellout.error?
        Chef::Log.error(
          "boxcutter_onepassword[#{event}]: exitstatus=#{shellout.exitstatus} " \
          "command=#{command.inspect} env_keys=#{(env || {}).keys.sort.inspect} extra=#{extra.inspect} " \
          "stdout=#{truncate(shellout.stdout)} stderr=#{truncate(shellout.stderr)}",
        )
        shellout.error!
      end

      Chef::Log.debug("boxcutter_onepassword[#{event}]: stdout=#{truncate(shellout.stdout)}") if log_stdout

      Chef::Log.info(
        "boxcutter_onepassword[#{event}]: ok " \
        "exitstatus=#{shellout.exitstatus} extra=#{extra.inspect}",
      )
      shellout
    end

    def self.truncate(s)
      str = (s || '').to_s
      return str if str.length <= STDIO_TRUNCATE
      str[0, STDIO_TRUNCATE] + "...(truncated #{str.length - STDIO_TRUNCATE} chars)"
    end

    # This produces a little summary like:
    # {"OP_CONNECT_HOST"=>"env", "OP_CONNECT_TOKEN"=>"file"} without values.
    def self.summarize_token_sources(env)
      out = {}
      env.each_key do |k|
        out[k] =
          if ENV.key?(k)
            'env'
          else
            'file'
          end
      end
      out.inspect
    end
  end
end
