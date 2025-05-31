#
# Cookbook:: boxcutter_prometheus_test
# Recipe:: prometheus
#

case node['kernel']['machine']
when 'x86_64', 'amd64'
  node.default['boxcutter_prometheus']['prometheus']['source'] = \
    'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus/prometheus/releases/download/v3.4.0/prometheus-3.4.0.linux-amd64.tar.gz'
  node.default['boxcutter_prometheus']['prometheus']['checksum'] = \
    'e9d80c21f9c4aeefebcc1ab909b1a0cbaaa0950c22ae34cdeda9143ac2392a46'
  node.default['boxcutter_prometheus']['prometheus']['creates'] = \
    'prometheus-3.4.0.linux-amd64'
when 'aarch64', 'arm64'
  node.default['boxcutter_prometheus']['prometheus']['source'] = \
    'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus/prometheus/releases/download/v3.4.0/prometheus-3.4.0.linux-arm64.tar.gz'
  node.default['boxcutter_prometheus']['prometheus']['checksum'] = \
    '88a8c65743ead3952455da041750756405e6517e9007daee34f2afa30a12eef4'
  node.default['boxcutter_prometheus']['prometheus']['creates'] = \
    'prometheus-3.4.0.linux-arm64'
end

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

include_recipe 'boxcutter_prometheus::prometheus'
