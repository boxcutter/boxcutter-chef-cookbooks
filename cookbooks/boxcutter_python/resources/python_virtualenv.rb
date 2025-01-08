provides :boxcutter_python_virtualenv

property :path, String,
         description: 'The path to create the virtual environment.',
         name_property: true
property :interpreter, String,
         description: 'The Python interpreter used to run commands to configure the virtualenv',
         default: '/usr/bin/python3'
property :user, [String, Integer],
         description: 'The user name or user ID used to run commands in the Python interpreter.',
         default: 'root'
property :group, [String, Integer],
         description: 'The group name or group ID used to run commands in the Python interpreter.',
         default: 'root'
property :system_site_packages, [true, false],
         description: 'Install globally available packages to the system site-packages directory',
         default: false
property :copies, [true, false],
         description: 'Use copies rather than symlinks',
         default: false
property :clear, [true, false],
         description: 'Delete the contents of the virtual environment directory if it already exists, before creating',
         default: false
property :upgrade_deps, [true, false],
         description: 'Upgrade pip + setuptools to the latest on PyPI',
         default: true
property :without_pip, [true, false],
         description: 'Do not install pip in the virtualenv',
         default: false
property :prompt, String,
         description: 'Set the prompt inside the virtualenv'
property :extra_options, String,
         description: 'Extra options to pass to the virtualenv command'

PYVENV_CFG = 'pyvenv.cfg'.freeze

load_current_value do |new_resource|
  pyvenv_cfg_path = ::File.join(new_resource.path, PYVENV_CFG)
  if ::File.exist?(pyvenv_cfg_path)
    config = Boxcutter::Python::Helpers.read_pyvenv_cfg(pyvenv_cfg_path)
    system_site_packages config['include-system-site-packages'] == 'true'
    if config.key?('prompt')
      prompt Boxcutter::Python::Helpers.remove_surrounding_single_quotes(config['prompt'])
    end
  end
end

action :create do
  pyvenv_cfg_path = ::File.join(new_resource.path, PYVENV_CFG)

  command = [new_resource.interpreter, '-m', 'venv']
  command << '--system-site-packages' if new_resource.system_site_packages
  command << '--copies' if new_resource.copies
  command << '--clear' if new_resource.clear
  command << '--without-pip' if new_resource.without_pip
  command << "--prompt #{new_resource.prompt}" if new_resource.prompt
  command << '--upgrade-deps' if new_resource.upgrade_deps && !node.ubuntu20?
  command << extra_options if new_resource.extra_options
  command << new_resource.path
  command_line = command.join(' ')

  execute 'create virtualenv' do
    command command_line
    user new_resource.user
    group new_resource.group
    creates pyvenv_cfg_path
  end

  converge_if_changed :prompt do
    # https://github.com/chef/chef/issues/7043
    file ::File.join(new_resource.path, PYVENV_CFG) do
      # The the string in the prompt field is enclosed by single quotes,
      # like so: `prompt = 'venv'`
      # Make sure we add this to searches and our prompt string.
      content IO.read(pyvenv_cfg_path).gsub(/^prompt = '.+'/, "prompt = '#{new_resource.prompt}'")
    end
  end
end

action :delete do
  directory new_resource.path do
    recursive true
    action :delete
  end
end
