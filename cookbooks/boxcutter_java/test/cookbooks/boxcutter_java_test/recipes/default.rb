#
# Cookbook:: boxcutter_java_test
# Recipe:: default
#

node.default['boxcutter_java']['sdkman'] = {
  '/home/java/.sdkman' => {
    'user' => 'java',
    'group' => 'java',
    'candidates' => {
      'java' => '11.0.24-tem',
    },
  },
}

FB::Users.initialize_group(node, 'java')
node.default['fb_users']['users']['java'] = {
  'gid' => 'java',
  'shell' => '/bin/bash',
  'action' => :add,
}

include_recipe 'boxcutter_java::default'
