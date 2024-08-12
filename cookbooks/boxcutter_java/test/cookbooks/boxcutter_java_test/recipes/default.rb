#
# Cookbook:: boxcutter_java_test
# Recipe:: default
#

java_user = 'java'
java_group = 'java'
java_home = '/home/java'

node.default['boxcutter_java']['sdkman'] = {
  ::File.join(java_home, '.sdkman') => {
    'user' => java_user,
    'group' => java_group,
    'candidates' => {
      'java' => '11.0.24-tem',
    },
  },
}

FB::Users.initialize_group(node, java_user)
node.default['fb_users']['users'][java_user] = {
  'gid' => java_group,
  'shell' => '/bin/bash',
  'action' => :add,
}

directory ::File.join(java_home, '.bashrc.d') do
  owner java_user
  group java_group
  mode '0700'
end

template ::File.join(java_home, '.bashrc.d', '100.sdkman.bashrc') do
  source 'sdkman.bashrc.erb'
  owner java_user
  group java_group
  mode '0700'
end

template ::File.join(java_home, '.bashrc') do
  source 'java.bashrc.erb'
  owner java_user
  group java_group
  mode '0644'
end

include_recipe 'boxcutter_java::default'
