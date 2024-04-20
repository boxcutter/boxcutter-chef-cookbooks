module Boxcutter
  class OnePassword
    def self.op_read(reference)
      if op_connect_server_token_found?
        environment = {
          'OP_CONNECT_HOST' => token_from_env_or_file('OP_CONNECT_TOKEN', op_connect_host_path),
          'OP_CONNECT_TOKEN' => token_from_env_or_file('OP_CONNECT_TOKEN', op_connect_token_path),
        }
      elsif op_service_account_token_found?
        environment = {
          'OP_SERVICE_ACCOUNT_TOKEN' => token_from_env_or_file('OP_SERVICE_ACCOUNT_TOKEN',
                                                               op_service_account_token_path),
        }
      else
        fail 'polymath_onepassword[op_read]: 1Password token not found'
      end
      command = '/usr/local/bin/op user get --me'
      shellout = Mixlib::ShellOut.new(command, env: environment)
      shellout.run_command
      shellout.error!
      Chef::Log.debug("boxcutter_onepassword[op_read]: op user get --me\n#{shellout.stdout}")

      command = "/usr/local/bin/op read '#{reference}'"
      shellout = Mixlib::ShellOut.new(command, env: environment)
      shellout.run_command
      shellout.error!
      shellout.stdout.strip
    end

    def self.encrypted_data_bag_secret_directory
      return '/etc/chef' unless Chef::Config[:encrypted_data_bag_secret]
      encrypted_data_bag_secret_path = Chef::Config[:encrypted_data_bag_secret]
      ::File.dirname(encrypted_data_bag_secret_path)
    end

    def self.op_connect_host_path
      ::File.join(encrypted_data_bag_secret_directory, 'op_connect_host')
    end

    def self.op_connect_token_path
      ::File.join(encrypted_data_bag_secret_directory, 'op_connect_token')
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
      ::File.join(encrypted_data_bag_secret_directory, 'op_service_account_token')
    end

    def self.op_service_account_token_found?
      Chef::Log.debug('boxcutter_onepassword: probing for 1Password Service Account token')
      if ENV['OP_SERVICE_ACCOUNT_TOKEN']
        Chef::Log.debug('boxcutter_onepassword: OP_SERVICE_ACCOUNT_TOKEN environment variable found!')
        return true
      end

      if ::File.exist?(op_service_account_token_path)
        Chef::Log.debug("boxcutter_onepassword: #{op_service_account_token_path} file found!")
        return true
      end

      Chef::Log.debug('boxcutter_onepassword: 1Password Service Account token NOT found')
      return false
    end

    def self.token_from_env_or_file(environment_variable_name, file_path)
      if ENV[environment_variable_name]
        Chef::Log.debug("boxcutter_onepassword[token_from_env_or_file]: Using 1Password " +
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
