module Boxcutter
  class OnePassword
    def self.op_whoami(type = 'auto')
      command = "#{op_cli} whoami"
      shellout = Mixlib::ShellOut.new(command, :env => op_environment(type))
      shellout.run_command
      shellout.error!
      shellout.stdout.strip
    end

    def self.op_read(reference, type = 'auto')
      environment = op_environment(type)
      cli = op_cli

      # 1Password Connect Server does not support op user get --me
      if ['auto', 'service_account'].include?(type)
        command = "#{cli} user get --me"
        shellout = Mixlib::ShellOut.new(command, :env => environment)
        shellout.run_command
        shellout.error!
        Chef::Log.debug("boxcutter_onepassword[op_read]: op user get --me\n#{shellout.stdout}")
      end

      command = "#{cli} read '#{reference}'"
      shellout = Mixlib::ShellOut.new(command, :env => environment)
      shellout.run_command
      shellout.error!
      shellout.stdout.strip
    end

    def self.op_document_get(item, vault, type = 'auto')
      environment = op_environment(type)

      op_document_cmd = [op_cli, 'document', 'get', "'#{item}'"]
      op_document_cmd << "--vault '#{vault}'" unless vault.nil?

      command = op_document_cmd.join(' ')
      puts "MISCHA op_document_get: #{command}"
      puts "MISCHA environment: #{environment}"
      shellout = Mixlib::ShellOut.new(command, :env => environment)
      shellout.run_command
      shellout.error!
      shellout.stdout.strip
    end

    def self.op_environment(type)
      puts "MISCHA op_read type=#{type}"
      if op_connect_server_token_found? && ['auto', 'connect_server'].include?(type)
        environment = {
          'OP_CONNECT_HOST' => token_from_env_or_file('OP_CONNECT_TOKEN', op_connect_host_path),
          'OP_CONNECT_TOKEN' => token_from_env_or_file('OP_CONNECT_TOKEN', op_connect_token_path),
        }
      elsif op_service_account_token_found? && ['auto', 'service_account'].include?(type)
        environment = {
          'OP_SERVICE_ACCOUNT_TOKEN' => token_from_env_or_file('OP_SERVICE_ACCOUNT_TOKEN',
                                                               op_service_account_token_path),
        }
      else
        fail 'boxcutter_onepassword[op_read]: 1Password token not found'
      end

      environment
    end

    def self.bootstrap_op_cli
      '/opt/onepassword/bin/op'
    end

    def self.op_cli
      if !::File.exist?('/usr/bin/op')
        install_bootstrap_op_cli
        return bootstrap_op_cli
      end

      '/usr/bin//op'
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
      puts "MISCHA: architecture #{architecture}"

      # https://releases.1password.com/developers/cli/
      url = 'https://cache.agilebits.com/dist/1P/op2/pkg/v2.31.1/op_linux_amd64_v2.31.1.zip'
      if ['aarch64', 'arm64'].include?(architecture)
        url = 'https://cache.agilebits.com/dist/1P/op2/pkg/v2.31.1/op_linux_arm64_v2.31.1.zip'
      end
      tmp_path = ::File.join(Chef::Config[:file_cache_path], ::File.basename(url))

      uri = URI.parse(url)

      # Open a connection and download the file
      Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new(uri)
        http.request(request) do |response|
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
      ::File.chmod(0o755, ::File.join(bootstrap_op_cli_dirname, 'op'))
    end

    def self.unzip_file(zip_file, filename, destination)
      Zip::File.open(zip_file) do |zip|
        entry = zip.find_entry(filename)
        if entry
          target_path = ::File.join(destination, entry.name)
          # Skip extraction if file already exists
          if ::File.exist?(target_path)
            puts "#{target_path} already exists. Skipping extraction."
          else
            ::FileUtils.mkdir_p(File.dirname(target_path))
            entry.extract(target_path)
            puts "Extracted #{filename} to #{destination}" # Mimic quiet mode by reducing output
          end
        else
          puts "File #{filename} not found in the archive."
        end
      end
    end

    def self.op_secret_directory
      '/etc/chef'
    end

    def self.op_connect_host_path
      ::File.join(op_secret_directory, 'op_connect_host')
    end

    def self.op_connect_token_path
      ::File.join(op_secret_directory, 'op_connect_token')
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
      ::File.join(op_secret_directory, 'op_service_account_token')
    end

    def self.op_service_account_token_found?
      Chef::Log.debug('boxcutter_onepassword: probing for 1Password Service Account token')
      puts 'MISCHA: boxcutter_onepassword: probing for 1Password Service Account token'
      if ENV['OP_SERVICE_ACCOUNT_TOKEN']
        Chef::Log.debug('boxcutter_onepassword: OP_SERVICE_ACCOUNT_TOKEN environment variable found!')
        puts 'MISCHA: boxcutter_onepassword: OP_SERVICE_ACCOUNT_TOKEN environment variable found!'
        return true
      end

      puts "MISCHA: op_service_account_token_path=#{op_service_account_token_path}"
      if ::File.exist?(op_service_account_token_path)
        Chef::Log.debug("boxcutter_onepassword: #{op_service_account_token_path} file found!")
        puts "MISCHA: boxcutter_onepassword: #{op_service_account_token_path} file found!"
        return true
      end

      Chef::Log.debug('boxcutter_onepassword: 1Password Service Account token NOT found')
      puts 'MISCHA: boxcutter_onepassword: 1Password Service Account token NOT found'
      return false
    end

    def self.token_from_env_or_file(environment_variable_name, file_path)
      if ENV[environment_variable_name]
        Chef::Log.debug('boxcutter_onepassword[token_from_env_or_file]: Using 1Password ' +
                        "token found in #{environment_variable_name} environment variable")
        return ENV[environment_variable_name]
      end

      if File.exist?(file_path)
        File.open(file_path, 'r') do |file|
          token = file.read.strip
          fail "boxcutter_onepassword[token_from_env_or_file]: #{file_path} empty" if token.empty?
          Chef::Log.debug("boxcutter_onepassword[token_from_env_or_file]: Using 1Password token found in #{file_path}")
          return token
        end
      end

      fail 'boxcutter_onepassword[op_service_account_token]: 1Password Service account token not found'
    end
  end
end
