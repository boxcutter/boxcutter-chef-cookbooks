#
# Cookbook:: boxcutter_python_test
# Recipe:: pyenv
#

python_user = 'python'
python_group = 'python'
python_home = '/home/python'

node.default['boxcutter_python']['pyenv'] = {
  ::File.join(python_home, '.pyenv') => {
    'user' => python_user,
    'group' => python_group,
    'default_python' => '3.8.13',
    'pythons' => {
      '3.8.13' => nil,
      '3.10.4' => nil,
    },
    'virtualenvs' => {
      'venv38' => {
        'python' => '3.8.13',
      },
      'venv310' => {
        'python' => '3.10.4',
      },
    },
  },
}

FB::Users.initialize_group(node, python_user)
node.default['fb_users']['users'][python_user] = {
  'home' => python_home,
  'shell' => '/bin/bash',
  'gid' => python_group,
  'action' => :add,
}

directory ::File.join(python_home, '.bashrc.d') do
  owner python_user
  group python_group
  mode '0700'
end

template ::File.join(python_home, '.bashrc.d', '100.pyenv.bashrc') do
  source 'pyenv.bashrc.erb'
  owner python_user
  group python_group
  mode '0700'
end

template ::File.join(python_home, '.bashrc') do
  source 'python.bashrc.erb'
  owner python_user
  group python_group
  mode '0644'
end

include_recipe 'boxcutter_python::default'

# boxcutter_python_pyenv_package 'flask' do
#   pyenv_root ::File.join(python_home, '.pyenv')
#   pyenv_version '3.8.13'
#   user python_user
#   group python_group
#   live_stream true
# end

# List out venvs with "pyenv versions"
boxcutter_python_pyenv_package 'vcstool' do
  pyenv_root '/home/python/.pyenv'
  pyenv_version '3.10.4/envs/venv310'
  user 'python'
  group 'python'
  live_stream true
end
