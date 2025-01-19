#
# Cookbook:: boxcutter_node_test
# Recipe:: default
#

volta_user = 'boxcutter'
volta_group = 'boxcutter'
volta_home = '/home/boxcutter/.volta'

node.default['boxcutter_node']['volta'] = {
  volta_home => {
    'user' => volta_user,
    'group' => volta_group,
    'toolchain' => {
      'node@22' => {
        'name' => 'node@22',
        'default' => true,
      },
      'node@20' => {
        'name' => 'node@20',
      },
    },
  },
  # ::File.join(java_home, '.sdkman') => {
  #   'user' => java_user,
  #   'group' => java_group,
  #   'candidates' => {
  #     'java' => {
  #       '8.0.382-tem' => nil,
  #       '17.0.12-tem' => nil,
  #     },
  #     'sbt' => {
  #       '1.10.1' => nil,
  #     },
  #   },
  # },
}

FB::Users.initialize_group(node, volta_user)
node.default['fb_users']['users'][volta_user] = {
  'gid' => volta_group,
  'shell' => '/bin/bash',
  'action' => :add,
}

include_recipe 'boxcutter_node::volta'
