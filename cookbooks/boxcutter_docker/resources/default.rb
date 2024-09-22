unified_mode true

class Helpers
  extend ::Boxcutter::Docker::Helpers
end

action :configure do
  # log 'Goodbye world'

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
      Boxcutter::Docker::Helpers.buildx_rm(builder_name, user_config['user'], user_config['group'])
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
              Boxcutter::Docker::Helpers.context_create(desired_context_name, append_builder_config, user_config['user'],
                                                        user_config['group'])
            end
            Boxcutter::Docker::Helpers.buildx_create_append(desired_builder_name, append_builder_config,
                                                            user_config['user'], user_config['group'])
          end
        end
      end
    end
  end

  # networks
  current_networks = Boxcutter::Docker::Helpers.network_ls

  node['boxcutter_docker']['networks'].each do |name, data|
    if !current_networks[name]
      Boxcutter::Docker::Helpers.network_create(name, data)
    end
  end

  # volumes
  current_volumes = Boxcutter::Docker::Helpers.volume_ls

  node['boxcutter_docker']['volumes'].each do |name, data|
    if !current_volumes[name]
      Boxcutter::Docker::Helpers.volume_create(name, data)
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
  current_containers = Boxcutter::Docker::Helpers.container_ls

  node['boxcutter_docker']['containers'].each do |name, data|
    desired_state = 'running'

    if !current_containers[name]
      if desired_state == 'running'
        Boxcutter::Docker::Helpers.container_run(name, data)
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
