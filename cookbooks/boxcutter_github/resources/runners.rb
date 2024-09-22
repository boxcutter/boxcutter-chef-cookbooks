unified_mode true

action :manage do
  current_configs = current_runner_configs
  current_runners = current_configs.map { |config| config['install_directory'] }
  desired_runners = node['boxcutter_github']['github_runner']['runners'].keys
  puts "MISCHA: current_runners=#{current_runners}"
  puts "MISCHA: desired_runners=#{desired_runners}"
  runners_to_unregister = current_runners - desired_runners
  puts "MISCHA: runners_to_unregister=#{runners_to_unregister}"
  Chef::Log.info("current_runners=#{current_runners}, runners_to_unregister=#{runners_to_unregister}")
  runners_to_unregister.each do |install_directory|
    puts "MISCHA: Going to unregister install_directory=#{install_directory}"
    # runner_config = current_config.find { |config| config['install_directory'] == install_directory }

    boxcutter_github_runner install_directory do
      action [:unregister]
    end
  end

  node['boxcutter_github']['github_runner']['runners'].each do |install_directory, runner_config|
    boxcutter_github_runner install_directory do
      runner_name runner_config['runner_name']
      url runner_config['url']
      owner runner_config['owner']
      group runner_config['group']
      disable_update runner_config['disable_update']
      labels runner_config['labels']
      action [:register]
    end
  end
end

action_class do
  def current_runner_configs
    runner_configs = []
    # Best we can do to get the list of currently installed runners is search
    # through `/etc/systemd/system` for service units that start with
    # "actions.runner.*"
    custom_unit_file_root = '/etc/systemd/system'
    actions_runner_pattern = /^actions\.runner\..*\.service$/
    Dir.foreach(custom_unit_file_root) do |filename|
      if filename.match?(actions_runner_pattern)
        runner_config = {}
        working_directory = get_working_directory(::File.join(custom_unit_file_root, filename))
        next if working_directory.nil?
        runner_local_config_file = ::File.join(working_directory, '.runner')
        next unless ::File.exist?(runner_local_config_file)
        # .NET writes out config files with a byte-order mark, which Ruby can't
        # parse by default. Tell ruby that it is encoded with a BOM.
        runner_local_config = ::File.read(runner_local_config_file, encoding: 'bom|utf-8')
        runner_json = JSON.parse(runner_local_config)
        runner_config['runner_name'] = runner_json['name']
        runner_config['id'] = runner_json['id']
        # Get the directory one level up from the working directory
        runner_config['install_directory'] = ::File.expand_path('..', working_directory)
        runner_config['service_name'] = filename
        runner_configs << runner_config if runner_json.key?('agentId')
      end
    end
    runner_configs
  end

  def get_working_directory(unit_file_path)
    working_directory = nil
    service_section = false

    ::File.foreach(unit_file_path) do |line|
      line.strip!

      # Check if we are in the Service section
      if line == '[Service]'
        service_section = true
      elsif line.start_with?('[') # Check if we entered another section
        service_section = false
      end

      # If we are in the ServiceSection, look for the WorkingDirectory
      if service_section && line.start_with?('WorkingDirectory=')
        # Extract the value of WorkingDirectory and break form the loop
        working_directory = line.split('=')[1].strip
        break
      end
    end

    # Return the found value, or nil if not found
    working_directory
  end
end

# action :manage do
#   if local_gitlab_runner_config.key?('runners')
#     current_runners = local_gitlab_runner_config['runners'].map { |hash| hash['name'] }
#     desired_runners = node['polymath_gitlab_runner']['runners'].keys
#     runners_to_delete = current_runners - desired_runners
#     Chef::Log.info("current_runners=#{current_runners}, runners_to_delete=#{runners_to_delete}")
#     runners_to_delete.each do |description|
#       polymath_gitlab_runner_runner description do
#         action :unregister
#       end
#     end
#   end
#
#   node['polymath_gitlab_runner']['runners'].each do |description, runner_config|
#     polymath_gitlab_runner_runner description do
#       executor runner_config['executor']
#       paused runner_config['paused']
#       # These properties may soon be deprecated as sensitive
#       tag_list runner_config['tag_list']
#       run_untagged runner_config['run_untagged']
#       locked runner_config['locked']
#       access_level runner_config['access_level']
#       action :register
#     end
#   end
# end
#
# action_class do
#   def local_gitlab_runner_config
#     @local_gitlab_runner_config ||= Tomlrb.load_file('/etc/gitlab-runner/config.toml')
#   end
# end
