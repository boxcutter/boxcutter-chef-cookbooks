#
# Cookbook:: boxcutter_prometheus_test
# Recipe:: default
#

# node.default['boxcutter_prometheus']['prometheus']['config'] = {
#   'global' => {
#     'scrape_interval' => '10s',
#   },
#   'scrape_configs' => [
#     {
#       'job_name' => 'prometheus',
#       'static_configs' => [
#         {
#           'targets' => ['localhost:9090'],
#         }
#       ]
#     }
#   ]
# }

# node.default['boxcutter_prometheus']['prometheus']['config'] = {
#   'global' => {
#     'scrape_interval' => '10s',
#   },
#   'scrape_configs' => [
#     {
#       'job_name' => 'prometheus',
#       'static_configs' => [
#         {
#           'targets' => ['localhost:9090'],
#         }
#       ]
#     },
#     {
#       'job_name' => 'node',
#       'static_configs' => [
#         {
#           'targets' => ['localhost:9100'],
#         }
#       ]
#     }
#   ]
# }

node.default['boxcutter_prometheus']['prometheus']['config'] = {
  'global' => {
    'scrape_interval' => '10s',
    'evaluation_interval' => '10s',
  },
  # 'rule_files' => ['rules.yml'],
  'alerting' => {
    'alertmanagers' => [
      {
        'static_configs' => [
          'targets' => ['localhost:9093'],
        ]
      }
    ]
  },
  'scrape_configs' => [
    {
      'job_name' => 'prometheus',
      'static_configs' => [
        {
          'targets' => ['localhost:9090'],
        }
      ]
    },
    {
      'job_name' => 'node',
      'static_configs' => [
        {
          'targets' => ['localhost:9100'],
        }
      ]
    }
  ]
}

include_recipe 'boxcutter_prometheus::prometheus'
include_recipe 'boxcutter_prometheus::pushgateway'
include_recipe 'boxcutter_prometheus::node_exporter'
include_recipe 'boxcutter_prometheus::blackbox_exporter'
include_recipe 'boxcutter_prometheus::alertmanager'

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
