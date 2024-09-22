# Cannot easily stub methods in actions_class for chefspec, so instead the
# methods are here in libraries
module Boxcutter
  class Docker
    module Helpers
      # contexts
      def self.context_ls(user, group)
        cmd = Mixlib::ShellOut.new(
          'docker context ls --format json',
          login: true,
          user: user,
          group: group,
        ).run_command
        cmd.error!
        contexts = []
        # `docker context ls` outputs multiple JSON objects, each on a new line.
        # So we need to parse the output line by line and store each in an array
        cmd.stdout.each_line do |line|
          context = JSON.parse(line)
          contexts.push(context)
        end
        contexts
      end

      def self.context_create_command(name, data)
        cmd = ['docker context create']
        cmd << "--description '#{data['description']}'" if data.key?('description')
        cmd << "--docker '#{data['endpoint']}'" if data.key?('endpoint')
        cmd << name
        puts "MISCHA: context_create_command(#{name}, #{data}) = #{cmd.join(' ')}"
        cmd.join(' ')
      end

      def self.context_create(name, data, user, group)
        cmd = Mixlib::ShellOut.new(
          context_create_command(name, data),
          login: true,
          user: user,
          group: group,
          ).run_command
        cmd.error!
      end

      def self.context_rm_command(name)
        cmd = ['docker context rm']
        cmd << name
        puts "MISCHA: context_rm_command(#{name}) = #{cmd.join(' ')}"
        cmd.join(' ')
      end

      def self.context_rm(name, user, group)
        cmd = Mixlib::ShellOut.new(
          context_rm_command(name),
          login: true,
          user: user,
          group: group,
          ).run_command
        cmd.error!
      end

      # buildkits
      def self.buildx_ls(home)
        # Currently the output of `docker buildx ls --format ls` is essentially
        # unparseable in an automated way. Work is being done to remedy this but
        # doesn't seem like it will land anytime soon, so instead look where the
        # config files are stored in ~/.docker/buildx
        # https://github.com/docker/buildx/pull/830
        buildx_instances_path = ::File.join(home, '.docker/buildx/instances')
        config_map = {}
        return config_map unless Dir.exist?(buildx_instances_path)
        Dir.foreach(buildx_instances_path) do |filename|
          next if ['.', '..'].include?(filename)

          file_path = ::File.join(buildx_instances_path, filename)
          if ::File.file?(file_path)
            begin
              json_content = ::File.read(file_path)
              config_map[filename] = JSON.parse(json_content)
            rescue JSON::ParserError => e
              puts "Error parsing JSON in file #{filename}: #{e.message}"
            rescue StandardError => e
              puts "Error reading file #{filename}: #{e.message}"
            end
          end
        end
        config_map
      end

      def self.buildx_create_command(name, config)
        cmd = ["docker buildx create --name #{name}"]
        if config['driver']
          cmd << "--driver #{config['driver']}"
        else
          cmd << '--driver docker-container'
        end
        cmd << '--use' if config.fetch('use', false)
        cmd << "--platform #{config['platform']}" if config['platform']
        cmd << '--bootstrap'
        cmd.join(' ')
      end

      def self.buildx_create(name, data, user, group)
        command = buildx_create_command(name, data)
        puts "MISCHA: buildx_create_command=#{command}"
        Chef::Log.debug("boxcutter_docker: buildx_create_command=#{command}")

        shellout = Mixlib::ShellOut.new(
          command,
          login: true,
          user: user,
          group: group,
          ).run_command
        shellout.error!
      end

      def self.buildx_create_append_command(parent_name, data)
        cmd = ["docker buildx create --append --name #{parent_name}"]
        cmd << data['name'] if data['name']
        cmd << "--platform #{data['platform']}" if data['platform']
        cmd.join(' ')
      end

      def self.buildx_create_append(parent_name, data, user, group)
        command = buildx_create_append_command(parent_name, data)
        puts "MISCHA: buildx_create_append_command=#{command}"
        Chef::Log.debug("boxcutter_docker: buildx_create_append_command=#{command}")
        # execute "docker buildx create append #{name}" do
        #   command command
        # end
        shellout = Mixlib::ShellOut.new(
          command,
          login: true,
          user: user,
          group: group,
          ).run_command
        shellout.error!
      end

      def self.buildx_rm_command(name)
        cmd = ["docker buildx rm --force #{name}"]
        cmd.join(' ')
      end

      def self.buildx_rm(name, user, group)
        command = buildx_rm_command(name)
        puts "MISCHA: buildx_rm_command=#{command}"
        Chef::Log.debug("boxcutter_docker: buildx_rm_command=#{command}")
        shellout = Mixlib::ShellOut.new(
          command,
          login: true,
          user: user,
          group: group,
          ).run_command
        shellout.error!
      end

      # networks
      def self.network_ls
        result = Mixlib::ShellOut.new(
          'docker network ls --no-trunc --format "{{json .}}"',
        ).run_command
        result.error!
        networks = {}
        result.stdout.each_line do |line|
          data = JSON.parse(line.strip)
          networks[data['Name']] = {
            'driver' => data['Driver'],
            'labels' => data['Labels'],
          }
        end
        networks
      end

      def self.network_create_command(name, _data)
        "docker network create #{name}"
      end

      def self.network_create(name, data)
        command = network_create_command(name, data)
        puts "MISCHA: network_create_command=#{command}"
        Chef::Log.debug("boxcutter_docker: network_create_command=#{command}")
        execute "docker network create #{name}" do
          command command
        end
      end

      # volumes
      def self.volume_ls
        result = Mixlib::ShellOut.new(
          'docker volume ls --format "{{json .}}"',
        ).run_command
        result.error!
        volumes = {}
        result.stdout.each_line do |line|
          data = JSON.parse(line.strip)
          volumes[data['Name']] = {
            'mountpoint' => data['Mountpoint'],
            'driver' => data['Driver'],
            'labels' => data['Labels'],
          }
        end
        volumes
      end

      def self.volume_create_command(name, data)
        driver = data['driver'] || 'local'
        "docker volume create --driver #{driver} #{name}"
      end

      def self.volume_create(name, data)
        command = volume_create_command(name, data)
        puts "MISCHA: volume_create_command=#{command}"
        Chef::Log.debug("boxcutter_docker: volume_create_command=#{command}")
        execute "volume create #{name}" do
          command command
        end
      end

      # containers
      def self.container_ls
        result = Mixlib::ShellOut.new(
          'docker container ls --all --no-trunc --format "{{json .}}"',
        ).run_command
        result.error!
        containers = {}
        result.stdout.each_line do |line|
          data = JSON.parse(line.strip)
          containers[data['Names'].downcase] = {
            'id' => data['ID'],
            'image' => data['Image'],
            'status' => data['Status'].split[0].downcase,
          }
        end
        containers
      end

      def self.container_run_command(name, data)
        env = data['environment']&.map do |key, value|
          "--env #{key}#{value ? "=#{value}" : ''}"
        end&.join(' ')
        ports = data['ports']&.map do |host_port, container_port|
          "-p #{host_port}:#{container_port}"
        end&.join(' ')
        mounts = data['mounts']&.map do |_name, options|
          "--mount #{options['type'] == 'bind' ? 'type=bind,' : ''}" \
          "source=#{options['source']},target=#{options['target']}"
        end&.join(' ')
        ulimits = data['ulimits']&.map do |key, value|
          "--ulimit #{key}#{value ? "=#{value}" : ''}"
        end&.join(' ')
        logging_options = data['logging_options']&.map do |key, value|
          "--log-opt #{key}#{value ? "=#{value}" : ''}"
        end&.join(' ')
        extra_options = data['extra_options']&.map do |key, value|
          if value.is_a?(Array)
            value.map { |v| "--#{key}=#{v}" }.join(' ')
          else
            "--#{key}#{value ? "=#{value}" : ''}"
          end
        end&.join(' ')
        command = [
          data['command'], data['command_args']
        ].compact.join(' ')
        "docker container run --detach #{env} #{ports} #{mounts} " +
          "#{ulimits} #{logging_options} #{extra_options} " +
          "--name #{name} #{data['image']} #{command}"
      end

      def self.container_run(name, data)
        command = container_run_command(name, data)
        # puts "MISCHA: container_run_command=#{command}"
        # Chef::Log.debug("boxcutter_docker: container_run_command=#{command}")
        execute "container run #{name}" do
          command command
        end
      end
    end
  end
end
