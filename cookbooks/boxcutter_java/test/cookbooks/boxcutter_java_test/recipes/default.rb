#
# Cookbook:: boxcutter_java_test
# Recipe:: default
#

java_user = 'boxcutter'
java_group = 'boxcutter'
java_home = '/home/boxcutter'

# https://whichjdk.com/
# https://medium.com/@javachampions/java-is-still-free-3-0-0-ocrt-2021-bca75c88d23b
node.default['boxcutter_java']['sdkman'] = {
  ::File.join(java_home, '.sdkman') => {
    'user' => java_user,
    'group' => java_group,
    'candidates' => {
      'java' => {
        '8.0.382-tem' => nil,
        '17.0.12-tem' => nil,
      },
      'sbt' => {
        '1.10.1' => nil,
      },
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
