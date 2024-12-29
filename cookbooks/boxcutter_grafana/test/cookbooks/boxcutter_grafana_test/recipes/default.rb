#
# Cookbook:: boxcutter_grafana_test
# Recipe:: default
#

include_recipe 'boxcutter_grafana::loki'

node.default['boxcutter_grafana']['grafana']['config'] = {
  'auth.anonymous' => {
    'enabled' => true,
    'org_name' => 'Main Org.',
    'org_role' => 'Admin',
  },
  'auth.basic' => {
    'enabled' => false,
  },
  'auth' => {
    'disable_login_form' => true,
  },
}

include_recipe 'boxcutter_grafana::grafana'

node.default['boxcutter_fluent']['fluent_bit']['config']['pipeline'] = {
  'inputs' => [
    {
      'name' => 'tail',
      'path' => '/var/log/*.log',
      'read_from_head' => 'true',
      'tag' => 'ubuntu',
    },
  ],
  'outputs' => [
    {
      'name' => 'loki',
      'match' => '*',
      'labels' => 'job=fluent-bit',
    },
  ],
}
include_recipe 'boxcutter_fluent::fluent_bit'
