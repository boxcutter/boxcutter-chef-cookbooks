# Cannot easily stub methods in actions_class for chefspec, so instead the
# methods are here in libraries
module Boxcutter
  class Docker
    module Helpers
      # contexts
      def self.context_ls(user, group)
        cmd = Mixlib::ShellOut.new(
          'docker context ls --format json',
          :login => true,
          :user => user,
          :group => group,
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
          :login => true,
          :user => user,
          :group => group,
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
          :login => true,
          :user => user,
          :group => group,
          ).run_command
        cmd.error!
      end

      # buildkits
      def self.buildx_ls(user, group)
        # https://github.com/docker/buildx/pull/1787
        # https://github.com/docker/buildx/pull/2138
        cmd = Mixlib::ShellOut.new(
          'docker buildx ls --no-trunc --format json',
          :login => true,
          :user => user,
          :group => group,
          ).run_command
        cmd.error!
        builder_instances = []
        # `docker buildx ls` outputs multiple JSON objects, each on a new line.
        # So we need to parse the output line by line and store each in an array
        cmd.stdout.each_line do |line|
          builder_instance = JSON.parse(line)
          builder_instances.push(builder_instance)
        end
        builder_instances
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
          :login => true,
          :user => user,
          :group => group,
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

        shellout = Mixlib::ShellOut.new(
          command,
          :login => true,
          :user => user,
          :group => group,
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
          :login => true,
          :user => user,
          :group => group,
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
        cmd = Mixlib::ShellOut.new(command).run_command
        cmd.error!
      end

      def self.network_rm_command(name)
        cmd = ['docker network rm']
        cmd << name
        puts "MISCHA: network_rm_command(#{name}) = #{cmd.join(' ')}"
        cmd.join(' ')
      end

      def self.network_rm(name)
        cmd = Mixlib::ShellOut.new(
          network_rm_command(name),
          ).run_command
        cmd.error!
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
        cmd = Mixlib::ShellOut.new(command).run_command
        cmd.error!
      end

      def self.volume_rm_command(name)
        cmd = ['docker volume rm']
        cmd << name
        puts "MISCHA: volume_rm_command(#{name}) = #{cmd.join(' ')}"
        cmd.join(' ')
      end

      def self.volume_rm(name)
        cmd = Mixlib::ShellOut.new(
          volume_rm_command(name),
        ).run_command
        cmd.error!
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
        log_opts = data['log_opts']&.map do |key, value|
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
          "#{ulimits} #{log_opts} #{extra_options} " +
          "--name #{name} #{data['image']} #{command}"
      end

      def self.container_run(name, data)
        command = container_run_command(name, data)
        # puts "MISCHA: container_run_command=#{command}"
        # Chef::Log.debug("boxcutter_docker: container_run_command=#{command}")
        cmd = Mixlib::ShellOut.new(command).run_command
        cmd.error!
      end

      def self.container_stop_command(name)
        cmd = ['docker container stop']
        cmd << name
        puts "MISCHA: container_stop_command(#{name}) = #{cmd.join(' ')}"
        cmd.join(' ')
      end

      def self.container_stop(name)
        cmd = Mixlib::ShellOut.new(
          container_stop_command(name),
          ).run_command
        cmd.error!
      end

      def self.container_start_command(name)
        cmd = ['docker container start']
        cmd << name
        puts "MISCHA: container_start_command(#{name}) = #{cmd.join(' ')}"
        cmd.join(' ')
      end

      def self.container_start(name)
        cmd = Mixlib::ShellOut.new(
          container_start_command(name),
          ).run_command
        cmd.error!
      end

      def self.container_rm_command(name)
        cmd = ['docker container rm']
        cmd << name
        puts "MISCHA: container_rm_command(#{name}) = #{cmd.join(' ')}"
        cmd.join(' ')
      end

      def self.container_rm(name)
        cmd = Mixlib::ShellOut.new(
          container_rm_command(name),
          ).run_command
        cmd.error!
      end
    end
  end
end
