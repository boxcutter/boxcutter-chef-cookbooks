unified_mode true

action :configure do
  # contexts
  all_contexts = context_ls

  node['boxcutter_docker']['contexts'].each do |name, data|
    if !all_contexts[name]
      context_create(name, data)
    end
  end

  # buildkits
  all_buildkits = buildx_ls

  node['boxcutter_docker']['buildkits'].each do |name, data|
    if !all_buildkits[name]
      buildx_create(name, data)
    end
  end

  # networks
  current_networks = network_ls

  node['boxcutter_docker']['networks'].each do |name, data|
    if !current_networks[name]
      network_create(name, data)
    end
  end

  # volumes
  current_volumes = volume_ls

  node['boxcutter_docker']['volumes'].each do |name, data|
    if !current_volumes[name]
      volume_create(name, data)
    end
  end

  # bind_mounts
  node['boxcutter_docker']['bind_mounts'].each do |resource_name, data|
    # log 'hi'
    name = data['path'] || resource_name

    directory name do
      group data['group']
      mode data['mode']
      owner data['owner']
    end
  end

  # containers
  current_containers = container_ls

  node['boxcutter_docker']['containers'].each do |name, data|
    desired_state = 'running'

    if !current_containers[name]
      if desired_state == 'running'
        container_run(name, data)
        service_action = :start
      end
    elsif desired_state == 'running'
      service_action = :start
    elsif desired_state == 'stopped'
      service_action = :stop
    end

    with_run_context :root do
      service "boxcutter_docker container #{name}" do
        provider Chef::Provider::Service::Simple
        start_command "docker container start #{name}"
        stop_command "docker container stop #{name}"
        status_command(
          "[ $(docker container ls --quiet --filter 'name=${name}' | wc -l) -gt 0 ]",
          )
        if data['only_if']
          only_if { data['only_if'].call }
        end
        data['restart_resources']&.each do |restart_resource|
          subscribes :restart, restart_resource
        end
        action service_action
      end
    end
  end
end

action_class do
  # contexts
  def context_ls
    result = shell_out!('docker context ls --format "{{json .}}"')
    contexts = {}
    result.stdout.each_line do |line|
      data = JSON.parse(line.strip)
      contexts[data['Name']] = {
        'docker_endpoint' => data['DockerEndpoint'],
        'context_type' => data['ContextType'],
        'current' => data['Current'],
      }
    end
    contexts
  end
  def context_create_command(name, data)
    cmd = ["docker context create #{name}"]
    cmd << data['docker_endpoint']
    cmd << '--use' if data.fetch('use', false)
    cmd.join(' ')
  end

  def context_create(name, data)
    command = context_create_command(name, data)
    execute "docker context create #{name}" do
      command command
    end
  end

  # buildkits
  def buildx_ls
    result = shell_out!('docker buildx ls --format "{{json .}}"')
    buildkits = {}
    result.stdout.each_line do |line|
      data = JSON.parse(line.strip)
      buildkits[data['Name']] = {
        'driver' => data['Driver'],
        'labels' => data['Labels'],
      }
    end
    buildkits
  end

  def buildx_create_command(name, data)
    cmd = ["docker buildx create --name #{name}"]
    cmd << '--use' if data.fetch('use', false)
    cmd.join(' ')
  end

  def buildx_create(name, data)
    command = buildx_create_command(name, data)
    puts "MISCHA: buildx_create_command=#{command}"
    Chef::Log.debug("boxcutter_docker: buildx_create_command=#{command}")
    execute "docker buildx create #{name}" do
      command command
    end
  end

  # networks
  def network_ls
    result = shell_out!('docker network ls --no-trunc --format "{{json .}}"')
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

  def network_create_command(name, _data)
    "docker network create #{name}"
  end

  def network_create(name, data)
    command = network_create_command(name, data)
    puts "MISCHA: network_create_command=#{command}"
    Chef::Log.debug("boxcutter_docker: network_create_command=#{command}")
    execute "docker network create #{name}" do
      command command
    end
  end

  # volumes
  def volume_ls
    result = shell_out!('docker volume ls --format "{{json .}}"')
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

  def volume_create_command(name, data)
    driver = data['driver'] || 'local'
    "docker volume create --driver #{driver} #{name}"
  end

  def volume_create(name, data)
    command = volume_create_command(name, data)
    puts "MISCHA: volume_create_command=#{command}"
    Chef::Log.debug("boxcutter_docker: volume_create_command=#{command}")
    execute "volume create #{name}" do
      command command
    end
  end

  # containers
  def container_ls
    result = shell_out!('docker container ls --all --no-trunc --format "{{json .}}"')
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

  def container_run_command(name, data)
    env = data['environment']&.map do |key, value|
      "--env #{key}#{value ? "=#{value}" : ''}"
    end&.join(' ')
    ports = data['ports']&.map do |host_port, container_port|
      "-p #{host_port}:#{container_port}"
    end&.join(' ')
    mounts = data['mounts']&.map do |_name, options|
      "--mount #{options['type'] == 'bind' ? 'type=bind,' : ''}source=#{options['source']},target=#{options['target']}"
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

  def container_run(name, data)
    command = container_run_command(name, data)
    # puts "MISCHA: container_run_command=#{command}"
    # Chef::Log.debug("boxcutter_docker: container_run_command=#{command}")
    execute "container run #{name}" do
      command command
    end
  end
end
