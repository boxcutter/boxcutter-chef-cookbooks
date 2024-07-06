unified_mode true

action :configure do
  containers = current_containers

  node['boxcutter_docker']['bind_mounts'].each do |resource_name, data|
    name = data['path'] || resource_name

    directory name do
      group data['group']
      mode data['mode']
      owner data['owner']
    end
  end

  node['boxcutter_docker']['containers'].each do |name, data|
    desired_state = 'running'

    if !containers[name]
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
      service "boxcutter_docker #{name}" do
        provider Chef::Provider::Service::Simple
        start_command "docker container start #{name}"
        stop_command "docker container stop #{name}"
        status_command(
          "[ $(docker container ls --filter 'name=${name}' --quiet | wc -l) -gt 0 ]",
          )
        action service_action
      end
    end
  end
end

action_class do
  def current_networks
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

  def current_volumes
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

  def current_containers
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
      "--env #{key}#{value ? '={value}' : ''}"
    end&.join(' ')
    ports = data['ports']&.map do |host_port, container_port|
      "-p #{host_port}:#{container_port}"
    end&.join(' ')
    mounts = data['mounts']&.map do |_name, options|
      "--mount #{options['type'] == 'bind' ? 'type=bind,' : ''}source=#{options['source']},target=#{options['target']}"
    end&.join(' ')
    command = [
      data['command'], data['command_args']
    ].compact.join(' ')
    "docker container run --detach #{env} #{ports} #{mounts} " +
      "--name #{name} #{data['image']} #{command}"
  end

  def container_run(name, data)
    command = container_run_command(name, data)
    puts "MISCHA: container_run_command=#{command}"
    Chef::Log.debug("boxcutter_docker: container_run_command=#{command}")
    execute "container run #{name}" do
      command command
    end
  end
end
