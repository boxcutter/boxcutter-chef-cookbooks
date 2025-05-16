#
# Cookbook:: boxcutter_prometheus_test
# Recipe:: redis_exporter
#

include_recipe 'boxcutter_redis::default'

case node['kernel']['machine']
when 'x86_64', 'amd64'
  node.default['boxcutter_prometheus']['redis_exporter']['source'] = \
    'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/oliver006/redis_exporter/releases/download/v1.72.0/redis_exporter-v1.72.0.linux-amd64.tar.gz'
when 'aarch64', 'arm64'
  node.default['boxcutter_prometheus']['redis_exporter']['source'] = \
    'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/oliver006/redis_exporter/releases/download/v1.72.0/redis_exporter-v1.72.0.linux-arm64.tar.gz'
end

include_recipe 'boxcutter_prometheus::redis_exporter'

node.default['boxcutter_prometheus']['prometheus']['config'] = {
  'global' => {
    'scrape_interval' => '15s',
  },
  'scrape_configs' => [
    {
      'job_name' => 'redis_exporter',
      'static_configs' => [
        {
          'targets' => ['localhost:9121'],
        },
      ],
    },
  ],
}

include_recipe 'boxcutter_prometheus::prometheus'
