#
# Cookbook:: boxcutter_prometheus_test
# Recipe:: prometheus
#

# case node['kernel']['machine']
# when 'x86_64', 'amd64'
#   node.default['boxcutter_prometheus']['prometheus']['source'] = \
#     'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus/prometheus/releases/download/v3.4.1/prometheus-3.4.1.linux-amd64.tar.gz'
#   node.default['boxcutter_prometheus']['prometheus']['checksum'] = \
#     '09203151c132f36b004615de1a3dea22117ad17e6d7a59962e34f3abf328f312'
#   node.default['boxcutter_prometheus']['prometheus']['creates'] = \
#     'prometheus-3.4.1.linux-amd64'
# when 'aarch64', 'arm64'
#   node.default['boxcutter_prometheus']['prometheus']['source'] = \
#     'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus/prometheus/releases/download/v3.4.1/prometheus-3.4.1.linux-arm64.tar.gz'
#   node.default['boxcutter_prometheus']['prometheus']['checksum'] = \
#     '2a85be1dff46238c0d799674e856c8629c8526168dd26c3de2cecfbfc6f9a0a2'
#   node.default['boxcutter_prometheus']['prometheus']['creates'] = \
#     'prometheus-3.4.1.linux-arm64'
# end

node.default['boxcutter_prometheus']['prometheus']['config'] = {
  'global' => {
    'scrape_interval' => '10s',
  },
  'scrape_configs' => [
    {
      'job_name' => 'prometheus',
      'static_configs' => [
        {
          'targets' => ['localhost:9090'],
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
