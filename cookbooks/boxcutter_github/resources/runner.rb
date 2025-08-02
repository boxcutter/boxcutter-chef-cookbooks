# https://docs.chef.io/custom_resource_glossary
unified_mode true

property :install_directory, String, :name_property => true
property :runner_name, String
property :url, String
property :owner, String
property :group, String
property :work_directory, String
property :labels, Array
property :disable_update, [true, false], :default => false

load_current_value do |new_resource|
  puts 'MISCHA: load_current_value'
  runner_config_file = ::File.join(new_resource.install_directory, 'latest', '.runner')
  if runner_config_file && ::File.exist?(runner_config_file)
    # .NET writes out config files with a byte-order mark, which Ruby can't
    # parse by default. Tell ruby that it is encoded with a BOM.
    runner_config = ::File.read(runner_config_file, :encoding => 'bom|utf-8')
    runner_json = JSON.parse(runner_config)
    puts "MISCHA: current_value agentName = #{runner_json['agentName']}"

    runner_name runner_json['agentName']
    url runner_json['gitHubUrl']
  end
end

action :register do
  if platform?('ubuntu') && node['platform_version'].start_with?('22')
    %w{
      liblttng-ust1
      libkrb5-3
      zlib1g
      libicu70
    }.each do |pkg|
      package pkg do
        action :upgrade
      end
    end
  elsif platform?('ubuntu') && node['platform_version'].start_with?('20')
    %w{
      liblttng-ust0
      libkrb5-3
      zlib1g
      libssl1.1
      libicu66
    }.each do |pkg|
      package pkg do
        action :upgrade
      end
    end
  end

  # https://github.com/actions/runner/releases
  case node['kernel']['machine']
  when 'x86_64', 'amd64'
    url = 'https://github.com/actions/runner/releases/download/v2.321.0/actions-runner-linux-x64-2.321.0.tar.gz'
    checksum = 'ba46ba7ce3a4d7236b16fbe44419fb453bc08f866b24f04d549ec89f1722a29e'
  when 'aarch64', 'arm64'
    url = 'https://github.com/actions/runner/releases/download/v2.321.0/actions-runner-linux-arm64-2.321.0.tar.gz'
    checksum = '62cc5735d63057d8d07441507c3d6974e90c1854bdb33e9c8b26c0da086336e1'
  end

  filename = ::File.basename(url)
  tmp_path = ::File.join(Chef::Config[:file_cache_path], filename)
  path = "#{new_resource.install_directory}/#{filename.gsub(/\.tar\.gz$/, '')}"

  [
    new_resource.install_directory,
    path,
  ].each do |dir|
    directory dir do
      owner new_resource.owner
      group new_resource.group
      mode '0700'
    end
  end

  remote_file tmp_path do
    source url
    checksum checksum
  end

  execute 'extract actions-runner' do
    command <<-BASH
      tar --extract --no-same-owner --directory #{path} --file #{tmp_path}
    BASH
    user new_resource.owner
    group new_resource.group
    creates "#{path}/config.sh"
  end

  link "#{new_resource.install_directory}/latest" do
    to path.to_s
    owner new_resource.owner
    group new_resource.group
  end

  converge_if_changed :runner_name do
    puts 'MISCHA: runner_name changed'
    puts "MISCHA: runner_name_registered? = #{runner_name_registered?(new_resource.runner_name)}"

    register_cmd = ['./config.sh']
    register_cmd << '--unattended'
    register_cmd << "--url #{new_resource.url}"
    register_cmd << "--token #{repository_create_registration_token(github_owner, github_repo)}"
    register_cmd << "--name #{new_resource.runner_name}"
    register_cmd << "--labels #{new_resource.labels.join(',')}" if new_resource.labels
    # --runnergroup
    # --labels
    # --no-default-labels
    # --work
    register_cmd << '--replace' if runner_name_registered?(new_resource.runner_name)
    register_cmd << '--disableupdate' if new_resource.disable_update

    execute 'register runner' do
      command register_cmd.join(' ')
      cwd runner_root
      live_stream true
      user new_resource.owner
      group new_resource.group
      not_if { ::File.exist?("#{runner_root}/.runner") }
    end
  end

  execute 'enable runner service' do
    command "./svc.sh install #{new_resource.owner}"
    cwd runner_root
    live_stream true
    not_if { service_installed? }
  end

  execute 'start runner service' do
    command './svc.sh start'
    cwd runner_root
    live_stream true
    not_if { service_running? }
  end
end

action :unregister do
  execute 'uninstall runner service' do
    command './svc.sh uninstall'
    cwd runner_root
    live_stream true
    only_if { service_installed? }
  end

  # We might be called without supplying any parameters besides the
  # install_directory, so try to figure out the current setup from the config
  # locations detected in current_resource
  uri = URI.parse(current_resource.url)
  match_data = uri.path.match(%r{^/([^/]+)/([^/]+)})
  current_github_owner = match_data[1]
  current_github_repo = match_data[2]

  config_file_stat = ::File.stat("#{runner_root}/config.sh")
  config_file_uid = config_file_stat.uid
  config_file_gid = config_file_stat.gid

  execute 'remove runner' do
    command <<-EOH
      ./config.sh remove \
        --token #{repository_create_remove_token(current_github_owner, current_github_repo)}
    EOH
    cwd runner_root
    live_stream true
    user config_file_uid
    group config_file_gid
    only_if { ::File.exist?("#{runner_root}/.runner") }
  end

  execute 'remove local' do
    command './config.sh remove --local'
    cwd runner_root
    live_stream
    user config_file_uid
    group config_file_gid
    only_if { ::File.exist?("#{runner_root}/.runner") }
  end
end

action_class do
  def runner_root
    "#{new_resource.install_directory}/latest"
  end

  def github_owner
    uri = URI.parse(new_resource.url)
    match_data = uri.path.match(%r{^/([^/]+)/([^/]+)})
    match_data[1]
  end

  def github_repo
    uri = URI.parse(new_resource.url)
    match_data = uri.path.match(%r{^/([^/]+)/([^/]+)})
    match_data[2]
  end

  def repository_runner?
    !github_repo.nil?
  end

  def boxcutter_self_hosted_runner_access_token
    # op item get 'GitHub self-hosted runner access token automation-org blue' --vault Automation-Org
    # op item get  tp2uhbjdoiv3crtwh7ytglxpcm --format json
    # op read 'op://Automation-Org/GitHub self-hosted runner access token automation-org blue/credential'
    return Boxcutter::OnePassword.op_read(
      'op://Automation-Org/GitHub self-hosted runner access token automation-org blue/credential',
    )
  end

  def repository_create_registration_token(owner, repo)
    gh_auth_login if needs_gh_cli_authentication?

    cmd = ['gh api']
    cmd << '--method POST'
    cmd << '-H "Accept: application/vnd.github+json"'
    cmd << '-H "X-GitHub-Api-Version: 2022-11-28"'
    cmd << "/repos/#{owner}/#{repo}/actions/runners/registration-token"
    command_to_execute = cmd.join(' ')

    shell_out = shell_out(command_to_execute, :login => true, :user => new_resource.owner, :group => new_resource.group)
    shell_out.error!
    parsed_stdout = JSON.parse(shell_out.stdout)
    parsed_stdout['token']
  end

  def repository_create_remove_token(owner, repo)
    gh_auth_login if needs_gh_cli_authentication?

    cli_user = new_resource.owner
    cli_group = new_resource.group
    runner_config_file = ::File.join(new_resource.install_directory, 'latest', '.runner')
    if runner_config_file && ::File.exist?(runner_config_file)
      config_file_stat = ::File.stat("#{runner_root}/config.sh")
      cli_user = config_file_stat.uid
      cli_group = config_file_stat.gid
    end

    cmd = ['gh api']
    cmd << '--method POST'
    cmd << '-H "Accept: application/vnd.github+json"'
    cmd << '-H "X-GitHub-Api-Version: 2022-11-28"'
    cmd << "/repos/#{owner}/#{repo}/actions/runners/remove-token"
    command_to_execute = cmd.join(' ')

    shell_out = shell_out(
      command_to_execute,
      :login => true,
      :user => cli_user,
      :group => cli_group,
)
    shell_out.error!
    parsed_stdout = JSON.parse(shell_out.stdout)
    parsed_stdout['token']
  end

  def repository_list_runners(owner, repo)
    gh_auth_login if needs_gh_cli_authentication?

    cmd = ['gh api']
    cmd << '-H "Accept: application/vnd.github+json"'
    cmd << '-H "X-GitHub-Api-Version: 2022-11-28"'
    cmd << "/repos/#{owner}/#{repo}/actions/runners"
    command_to_execute = cmd.join(' ')

    shell_out = shell_out(
      command_to_execute,
      :login => true,
      :user => new_resource.owner,
      :group => new_resource.group,
)
    shell_out.error!
    JSON.parse(shell_out.stdout)
  end

  def runner_name_registered?(name)
    if repository_runner?
      runner_json = repository_list_runners(github_owner, github_repo)
      return false unless runner_json.key?('runners')
      runner_json['runners'].each do |runner|
        puts "MISCHA runner_name_registerd? #{runner['name']}"
        if runner.key?('name') && runner['name'] == name
          return true
        end
      end
      false
    end
  end

  def service_installed?
    # Must run the svc.sh script as root and in the runner root
    command_to_execute = "#{runner_root}/svc.sh status"
    shell_out = Mixlib::ShellOut.new(
      command_to_execute,
      :cwd => "#{new_resource.install_directory}/latest",
).run_command
    shell_out.exitstatus == 0
  end

  def service_running?
    # Must run the svc.sh script as root and in the runner root
    unless ::File.exist?("#{runner_root}/svc.sh")
      fail "boxcutter_github: #{runner_root}/svc.h not found"
    end
    ::File.open("#{runner_root}/svc.sh", 'r') do |file|
      file.each_line do |line|
        match = line.match(/SVC_NAME="([^"]*)"/)
        next unless match

        value = match[1] # The value inside the quotes
        service_name = value
        return system("systemctl is-active --quiet #{service_name}")
      end
    end

    false
  end

  def needs_gh_cli_authentication?
    cli_user = new_resource.owner
    cli_group = new_resource.group
    runner_config_file = ::File.join(new_resource.install_directory, 'latest', '.runner')
    if runner_config_file && ::File.exist?(runner_config_file)
      config_file_stat = ::File.stat("#{runner_root}/config.sh")
      cli_user = config_file_stat.uid
      cli_group = config_file_stat.gid
    end

    gh_auth_status = Mixlib::ShellOut.new(
      'gh auth status',
      :login => true,
      :user => cli_user,
      :group => cli_group,
    ).run_command
    gh_auth_status.exitstatus != 0
  end

  def gh_auth_login
    cli_user = new_resource.owner
    cli_group = new_resource.group
    runner_config_file = ::File.join(new_resource.install_directory, 'latest', '.runner')
    if runner_config_file && ::File.exist?(runner_config_file)
      config_file_stat = ::File.stat("#{runner_root}/config.sh")
      cli_user = config_file_stat.uid
      cli_group = config_file_stat.gid
    end

    gh_auth_login = Mixlib::ShellOut.new(
      "echo #{boxcutter_self_hosted_runner_access_token} | gh auth login --with-token",
      :login => true,
      :user => cli_user,
      :group => cli_group,
    ).run_command
    gh_auth_login.error!
  end
end
