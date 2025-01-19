action :configure do
  node['boxcutter_node']['volta'].each do |volta_home, volta_config|
    execute 'run volta installer' do
      command <<-BASH
          curl https://get.volta.sh | bash -s -- --skip-setup
      BASH
      login true
      user volta_config['user']
      group volta_config['group']
      live_stream true
      creates ::File.join(volta_home, 'bin', 'volta')
    end

    volta_config['toolchain'].each do |tool_name, tool_config|
      tool_name_to_install = tool_name
      if tool_config.key?('name')
        tool_name_to_install = tool_config['name']
      end

      volta_path = ::File.join(volta_home, 'bin', 'volta')
      check_command = "#{volta_path} list all --format plain | grep #{tool_name_to_install}"
      result = shell_out(check_command, login: true, user: volta_config['user'], group: volta_config['group'])

      if result.exitstatus != 0
        puts "MISCHA: need to install #{tool_name_to_install}"
        install_command = "#{volta_path} install #{tool_name_to_install}"
        execute "install volta tool #{tool_name_to_install}" do
          command install_command
          login true
          user volta_config['user']
          group volta_config['group']
          live_stream true
        end
      else
        puts "MISCHA: volta tool #{tool_name_to_install} already installed"
      end
    end
  end
end
