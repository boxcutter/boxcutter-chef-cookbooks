unified_mode true

class Helpers
  extend ::Boxcutter::Docker::Helpers
end

action :configure do
  # buildx
  node['boxcutter_docker']['buildx'].each do |user, user_config|
    current_builders = Boxcutter::Docker::Helpers.buildx_ls(user_config['home'])
    puts "MISCHA: current_builders=#{current_builders}"
    current_builder_names = current_builders.values.map { |builder| builder['Name'] }.compact
    puts "MISCHA: current_builder_names=#{current_builder_names}"
    desired_builder_names = user_config['builders'].values.map { |builder| builder['name'] }.compact
    puts "MISCHA: desired_builder_names=#{desired_builder_names}"
    builder_names_to_delete = current_builder_names - desired_builder_names

    builder_names_to_delete.each do |builder_name|
      context_names_to_delete = current_builders.values.
                                map do |builder|
        builder['Nodes'].map { |node| node['Endpoint'] }.
          reject { |endpoint| endpoint == 'unix:///var/run/docker.sock' }.compact
      end
      puts "MISCHA: context_names_to_delete=#{context_names_to_delete}"
      Boxcutter::Docker::Helpers.buildx_rm(builder_name, user_config['user'], user_config['group'])
      context_names_to_delete.each do |context_name|
        Boxcutter::Docker::Helpers.context_rm(context_name, user_config['user'], user_config['group'])
      end
    end

    node['boxcutter_docker']['buildx'][user]['builders'].each do |_builder, builder_config|
      desired_builder_name = builder_config['name']
      puts "MISCHA: desired_builder_name=#{desired_builder_name}, builder_config=#{builder_config}"
      if !current_builder_names.include?(desired_builder_name)
        Boxcutter::Docker::Helpers.buildx_create(desired_builder_name, builder_config, user_config['user'],
                                                 user_config['group'])
        # log 'Goodbye world'
        current_contexts = Boxcutter::Docker::Helpers.context_ls(user_config['user'], user_config['group'])
        puts "MISCHA: current_contexts=#{current_contexts}"
        current_context_names = current_contexts.map { |item| item['Name'] }
        if builder_config['append']
          builder_config['append'].each do |_append_builder, append_builder_config|
            puts "MISCHA: append_builder_config=#{append_builder_config}"
            desired_context_name = append_builder_config['name']
            puts "MISCHA: desired_context_name=#{desired_context_name}"
            if !current_context_names.include?(desired_context_name)
              Boxcutter::Docker::Helpers.context_create(desired_context_name, append_builder_config,
                                                        user_config['user'], user_config['group'])
            end
            Boxcutter::Docker::Helpers.buildx_create_append(desired_builder_name, append_builder_config,
                                                            user_config['user'], user_config['group'])
          end
        end
      end
    end
  end

  # networks
  # List of network names to ignore
  ignored_default_network_names = ['bridge', 'host', 'none']
  current_networks = Boxcutter::Docker::Helpers.network_ls
  current_network_names = current_networks.keys - ignored_default_network_names
  puts "MISCHA: current_network_names=#{current_network_names}"
  desired_network_names = node['boxcutter_docker']['networks'].map do |name, data|
    # Allow for 'Name' attribute to override section name, if present
    data.fetch('name', name)
  end
  puts "MISCHA: desired_network_names=#{desired_network_names}"
  node['boxcutter_docker']['networks'].each do |name, data|
    # Allow for 'Name' attribute to override section name, if present
    network_name = data.fetch('name', name)

    if !current_network_names.include?(network_name)
      Boxcutter::Docker::Helpers.network_create(network_name, data)
    end
  end

  # volumes
  current_volumes = Boxcutter::Docker::Helpers.volume_ls
  current_volume_names = current_volumes.keys
  puts "MISCHA: current_volume_names=#{current_volume_names}"
  desired_volume_names = node['boxcutter_docker']['volumes'].map do |name, data|
    # Allow for 'Name' attribute to override section name, if present
    data.fetch('name', name)
  end
  puts "MISCHA: desired_volume_names=#{desired_volume_names}"
  node['boxcutter_docker']['volumes'].each do |name, data|
    # Allow for 'Name' attribute to override section name, if present
    volume_name = data.fetch('name', name)
    puts "MISCHA: volume name #{volume_name}"
    if !current_volume_names.include?(volume_name)
      Boxcutter::Docker::Helpers.volume_create(volume_name, data)
    end
  end

  # bind_mounts
  node['boxcutter_docker']['bind_mounts'].each do |resource_name, data|
    name = data['path'] || resource_name
    type = data['type'] || 'directory'

    if type == 'directory'
      directory name do
        group data['group']
        owner data['owner']
        mode data['mode']
      end
    elsif type =='file'
      file name do
        content data['content']
        owner data['owner']
        group data['group']
        mode data['mode']
      end
    end
  end

  # containers
  current_containers = Boxcutter::Docker::Helpers.container_ls
  current_container_names = current_containers.keys
  puts "MISCHA: current_container_names=#{current_container_names}"
  desired_container_names = node['boxcutter_docker']['containers'].map do |name, data|
    # Allow for 'Name' attribute to override section name, if present
    data.fetch('name', name)
  end
  puts "MISCHA: desired_container_names=#{desired_container_names}"

  node['boxcutter_docker']['containers'].each do |name, data|
    container_name = data.fetch('name', name)
    next if container_name.start_with?('__')

    action = data['action'] || 'run'
    service_action = :nothing
    if !current_containers[container_name]
      if action == 'run'
        Boxcutter::Docker::Helpers.container_run(container_name, data)
        service_action = :start
      else
        puts "MISCHA: container_name=#{container_name} action=#{action}"
      end
    elsif action == 'run'
      service_action = :start
      puts "MISCHA: container_name=#{container_name} action=#{action}"
    elsif action == 'stop'
      service_action = :stop
      puts "MISCHA: container_name=#{container_name} action=#{action}"
    else
      fail "polymath_docker: container_name=#{container_name} unknown action=#{action}"
    end

    with_run_context :root do
      service "boxcutter_docker container #{container_name}" do
        provider Chef::Provider::Service::Simple
        start_command "docker container start #{container_name}"
        stop_command "docker container stop #{container_name}"
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

  current_containers.each do |name, data|
    container_name = data.fetch('name', name)
    if !node['boxcutter_docker']['containers'][container_name]
      Boxcutter::Docker::Helpers.container_stop(container_name)
      Boxcutter::Docker::Helpers.container_rm(container_name)
      next
    end

    action = data['action'] || 'run'
    if action == 'stop' && data['status'] == 'running'
      Boxcutter::Docker::Helpers.container_stop(container_name)
    elsif action == 'run' && data['status'] != 'running'
      Boxcutter::Docker::Helpers.container_start(container_name)
    end
  end

  current_volumes.each do |name, data|
    # Allow for 'Name' attribute to override section name, if present
    volume_name = data.fetch('name', name)

    next if node['boxcutter_docker']['volumes'][volume_name]
    Boxcutter::Docker::Helpers.volume_rm(volume_name)
  end

  current_networks.each do |name, data|
    # Allow for 'Name' attribute to override section name, if present
    network_name = data.fetch('name', name)

    next if ignored_default_network_names.include?(network_name)
    next if node['boxcutter_docker']['networks'][network_name]
    Boxcutter::Docker::Helpers.network_rm(network_name)
  end
end
