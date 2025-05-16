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

# node.default['boxcutter_prometheus']['prometheus']['config'] = {
#   'global' => {
#     'scrape_interval' => '10s',
#     'evaluation_interval' => '10s',
#   },
#   # 'rule_files' => ['rules.yml'],
#   'alerting' => {
#     'alertmanagers' => [
#       {
#         'static_configs' => [
#           'targets' => ['localhost:9093'],
#         ],
#       },
#     ],
#   },
#   'scrape_configs' => [
#     {
#       'job_name' => 'prometheus',
#       'static_configs' => [
#         {
#           'targets' => ['localhost:9090'],
#         },
#       ],
#     },
#     {
#       'job_name' => 'node',
#       'static_configs' => [
#         {
#           'targets' => ['localhost:9100'],
#         },
#       ],
#     },
#   ],
# }

case node['kernel']['machine']
when 'x86_64', 'amd64'
  node.default['boxcutter_prometheus']['prometheus']['source'] = \
    'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus/prometheus/releases/download/v3.3.1/prometheus-3.3.1.linux-amd64.tar.gz'
when 'aarch64', 'arm64'
  node.default['boxcutter_prometheus']['prometheus']['source'] = \
    'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus/prometheus/releases/download/v3.3.1/prometheus-3.3.1.linux-arm64.tar.gz'
end

include_recipe 'boxcutter_prometheus::prometheus'

# include_recipe 'boxcutter_prometheus::pushgateway'
# include_recipe 'boxcutter_prometheus::node_exporter'
# include_recipe 'boxcutter_prometheus::blackbox_exporter'

case node['kernel']['machine']
when 'x86_64', 'amd64'
  node.default['boxcutter_prometheus']['alertmanager']['source'] = \
    'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus/alertmanager/releases/download/v0.28.1/alertmanager-0.28.1.linux-amd64.tar.gz'
when 'aarch64', 'arm64'
  node.default['boxcutter_prometheus']['alertmanager']['source'] = \
    'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus/alertmanager/releases/download/v0.28.1/alertmanager-0.28.1.linux-arm64.tar.gz'
end

include_recipe 'boxcutter_prometheus::alertmanager'

case node['kernel']['machine']
when 'x86_64', 'amd64'
  node.default['boxcutter_prometheus']['blackbox_exporter']['source'] = \
    'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus/blackbox_exporter/releases/download/v0.26.0/blackbox_exporter-0.26.0.linux-amd64.tar.gz'
when 'aarch64', 'arm64'
  node.default['boxcutter_prometheus']['blackbox_exporter']['source'] = \
    'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus/blackbox_exporter/releases/download/v0.26.0/blackbox_exporter-0.26.0.linux-arm64.tar.gz'
end

include_recipe 'boxcutter_prometheus::blackbox_exporter'

# case node['kernel']['machine']
# when 'x86_64', 'amd64'
#   node.default['boxcutter_prometheus']['alertmanager']['source'] = \
#     'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus/alertmanager/releases/download/v0.28.1/alertmanager-0.28.1.linux-amd64.tar.gz'
# when 'aarch64', 'arm64'
#   node.default['boxcutter_prometheus']['alertmanager']['source'] = \
#     'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus/alertmanager/releases/download/v0.28.1/alertmanager-0.28.1.linux-arm64.tar.gz'
# end

# node.default['boxcutter_grafana']['grafana']['config'] = {
#   'auth.anonymous' => {
#     'enabled' => true,
#     'org_name' => 'Main Org.',
#     'org_role' => 'Admin',
#   },
#   'auth.basic' => {
#     'enabled' => false,
#   },
#   'auth' => {
#     'disable_login_form' => true,
#   },
# }
#
# include_recipe 'boxcutter_grafana::grafana'

# node.default['fb_grafana']['config'] = {
#   'auth.anonymous' => {
#     'enabled' => true,
#     'org_name' => 'Main Org.',
#     'org_role' => 'Admin',
#   },
#   'auth.basic' => {
#     'enabled' => false,
#   },
#   'auth' => {
#     'disable_login_form' => true,
#   },
#   'paths' => {
#     'data' => '/var/lib/grafana',
#     'logs' => '/var/log/grafana',
#     'plugins' => '/var/lib/grafana/plugins',
#   },
#   'server' => {
#     # 'protocol' => 'https',
#     # 'http_port' => 3000,
#   },
# }

# include_recipe 'fb_grafana'

# node.default['fb_apt']['sources']['grafana']['url'] = 'https://crake-nexus.org.boxcutter.net/repository/grafana-oss-apt-proxy'
