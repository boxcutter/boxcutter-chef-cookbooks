#
# Cookbook:: boxcutter_anaconda_test
# Recipe:: default
#

anaconda_user = 'anaconda'
anaconda_group = 'anaconda'
anaconda_home = '/home/anaconda'

FB::Users.initialize_group(node, anaconda_user)
node.default['fb_users']['users'][anaconda_user] = {
  'home' => anaconda_home,
  'shell' => '/bin/bash',
  'gid' => anaconda_group,
  'action' => :add,
}

directory ::File.join(anaconda_home, '.bashrc.d') do
  owner anaconda_user
  group anaconda_group
  mode '0700'
end

template ::File.join(anaconda_home, '.bashrc.d', '110.anaconda.bashrc') do
  source 'anaconda.bashrc.erb'
  owner anaconda_user
  group anaconda_group
  mode '0700'
end

template ::File.join(anaconda_home, '.bashrc') do
  source 'bashrc.erb'
  owner anaconda_user
  group anaconda_group
  mode '0644'
end

node.default['boxcutter_anaconda']['config'] = {
  '/home/anaconda/miniconda3': {
    'user': anaconda_user,
    'group': anaconda_group,
    'condarc': {
      'auto_activate_base': false,
      'notify_outdated_conda': false,
    },
  },
}

include_recipe 'boxcutter_anaconda::default'

boxcutter_anaconda_package 'cmake' do
  anaconda_root '/home/anaconda/miniconda3'
  user 'anaconda'
  group 'anaconda'
end
