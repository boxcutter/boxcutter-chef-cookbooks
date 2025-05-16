#
# Cookbook:: boxcutter_prometheus_test
# Recipe:: prometheus
#

case node['kernel']['machine']
when 'x86_64', 'amd64'
  node.default['boxcutter_prometheus']['node_exporter']['source'] = \
    'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus/prometheus/releases/download/v3.3.1/prometheus-3.3.1.linux-amd64.tar.gz'
when 'aarch64', 'arm64'
  node.default['boxcutter_prometheus']['node_exporter']['source'] = \
    'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus/prometheus/releases/download/v3.3.1/prometheus-3.3.1.linux-arm64.tar.gz'
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
