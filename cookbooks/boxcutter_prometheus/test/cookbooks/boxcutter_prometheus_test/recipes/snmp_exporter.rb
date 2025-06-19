#
# Cookbook:: boxcutter_prometheus_test
# Recipe:: snmp_exporter
#

# case node['kernel']['machine']
# when 'x86_64', 'amd64'
#   node.default['boxcutter_prometheus']['snmp_exporter']['source'] = \
#     'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus/snmp_exporter/releases/download/v0.29.0/snmp_exporter-0.29.0.linux-amd64.tar.gz'
#   node.default['boxcutter_prometheus']['snmp_exporter']['checksum'] = \
#     'fd7ded886180063a8f77e1ca18cc648e44b318b9c92bcb3867b817d93a5232d6'
#   node.default['boxcutter_prometheus']['snmp_exporter']['creates'] = \
#     'snmp_exporter-0.29.0.linux-amd64'
# when 'aarch64', 'arm64'
#   node.default['boxcutter_prometheus']['snmp_exporter']['source'] = \
#     'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus/snmp_exporter/releases/download/v0.29.0/snmp_exporter-0.29.0.linux-arm64.tar.gz'
#   node.default['boxcutter_prometheus']['snmp_exporter']['checksum'] = \
#     'e590870ad2fcd39ea9c7d722d6e85aa6f1cc9e8671ff3f17feba12a6b5a3b47a'
#   node.default['boxcutter_prometheus']['snmp_exporter']['creates'] = \
#     'snmp_exporter-0.29.0.linux-arm64'
# end

node.default['boxcutter_prometheus']['snmp_exporter']['command_line_flags'] = {
  'web.listen-address' => ':9116',
}

# node.run_state['boxcutter_prometheus'] ||= {}
# node.run_state['boxcutter_prometheus']['snmp_exporter'] ||= {}
# node.run_state['boxcutter_prometheus']['snmp_exporter']['auth'] ||= {}
# node.run_state['boxcutter_prometheus']['snmp_exporter']['auth']['password'] = 'superseekret'
# node.run_state['boxcutter_prometheus']['snmp_exporter']['auth']['priv_password'] = 'superseekret'
#
# node.default['boxcutter_prometheus']['snmp_exporter']['auth']['version'] =
#   '3'
# node.default['boxcutter_prometheus']['snmp_exporter']['auth']['security_level'] =
#   'authPriv'
# node.default['boxcutter_prometheus']['snmp_exporter']['auth']['username'] =
#   'snmpreader'
# node.default['boxcutter_prometheus']['snmp_exporter']['auth']['auth_protocol'] =
#   'SHA'
# node.default['boxcutter_prometheus']['snmp_exporter']['auth']['priv_protocol'] =
#   'AES'

node.run_state['boxcutter_prometheus'] ||= {}
node.run_state['boxcutter_prometheus']['snmp_exporter'] ||= {}
node.run_state['boxcutter_prometheus']['snmp_exporter']['auth'] ||= {}
node.run_state['boxcutter_prometheus']['snmp_exporter']['auth']['community'] = 'seekretcommunity'
node.default['boxcutter_prometheus']['snmp_exporter']['auth']['version'] =
  '2'

include_recipe 'boxcutter_prometheus::snmp_exporter'

node.default['boxcutter_prometheus']['prometheus']['config'] = {
  'global' => {
    'scrape_interval' => '15s',
  },
  'scrape_configs' => [
    {
      'job_name' => 'snmp',
      'metrics_path' => '/snmp',
      'params' => {
        'auth' => ['default'],
        'module' => ['if_mib'],
      },
      'static_configs' => [
        {
          'targets' => ['10.137.56.1'],
        },
      ],
      'relabel_configs' => [
        {
          'source_labels' => ['__address__'],
          'target_label' => '__param_target',
        },
        {
          'source_labels' => ['__param_target'],
          'target_label' => 'instance',
        },
        {
          'target_label' => '__address__',
          'replacement' => 'localhost:9116',
        },
      ],
    },
  ],
}

node.default['boxcutter_prometheus']['prometheus']['command_line_flags'] = {
  'storage.tsdb.path' => '/var/lib/prometheus/data',
  'storage.tsdb.retention.time' => '30d',
  'storage.tsdb.retention.size' => '20GB',
  'web.listen-address' => '0.0.0.0:9090',
}

include_recipe 'boxcutter_prometheus::prometheus'

node.default['fb_grafana']['datasources']['prometheus'] = {
  'type' => 'prometheus',
  'orgId' => 1,
  'url' => 'http://localhost:9090',
  'access' => 'proxy',
  'isDefault' => true,
  'editable' => false,
}

node.default['fb_grafana']['config'] = {
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
  'paths' => {
    'data' => '/var/lib/grafana',
    'logs' => '/var/log/grafana',
    'plugins' => '/var/lib/grafana/plugins',
  },
  'server' => {
    'protocol' => 'http',
    'http_port' => 3000,
  },
}

include_recipe 'fb_grafana'
# https://grafana.com/grafana/dashboards/21962-snmp-exporter/
