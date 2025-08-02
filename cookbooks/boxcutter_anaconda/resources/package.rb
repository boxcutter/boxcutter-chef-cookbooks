unified_mode true

property :package_name, String, :name_property => true
property :channel, String
property :version, String
property :user, String
property :group, String
property :anaconda_root, String

action :install do
  command = ['conda install']
  command << "--channel #{new_resource.channel}" unless new_resource.channel.nil?
  command << package_string
  bash 'run conda install' do
    code conda_command_script(new_resource.anaconda_root, command.join(' '))
    user new_resource.user if new_resource.user
    group new_resource.group if new_resource.group
    login true
    live_stream true
    not_if { conda_package_installed? }
  end
end

action_class do
  def package_string
    if new_resource.version.nil?
      new_resource.package_name
    else
      "#{new_resource.package_name}==#{new_resource.version}"
    end
  end

  def conda_package_installed?
    command = %{conda list --full-name #{new_resource.package_name} | grep "^#{new_resource.package_name} "}
    cmd = Mixlib::ShellOut.new(
      'bash',
      :input => conda_command_script(new_resource.anaconda_root, command),
      :user => new_resource.user,
      :group => new_resource.group,
      :login => true,
      )
    cmd.run_command
    cmd.valid_exit_codes = [0, 1]
    cmd.error!
    cmd.exitstatus == 0
  end

  def conda_command_script(anaconda_root, command)
    <<~BASH
      # >>> conda initialize >>>
      __conda_setup="$('#{anaconda_root}/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
      if [ $? -eq 0 ]; then
          eval "$__conda_setup"
      else
          if [ -f "#{anaconda_root}/etc/profile.d/conda.sh" ]; then
              . "#{anaconda_root}/etc/profile.d/conda.sh"
          else
              export PATH="#{anaconda_root}/bin:$PATH"
          fi
      fi
      unset __conda_setup
      # <<< conda initialize <<<

      #{command}
    BASH
  end
end
