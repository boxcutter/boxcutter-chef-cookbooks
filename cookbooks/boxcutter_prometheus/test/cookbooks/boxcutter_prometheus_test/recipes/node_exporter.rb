#
# Cookbook:: boxcutter_prometheus_test
# Recipe:: node_exporter
#

case node['kernel']['machine']
when 'x86_64', 'amd64'
  node.default['boxcutter_prometheus']['node_exporter']['source'] = \
    'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-amd64.tar.gz'
when 'aarch64', 'arm64'
  node.default['boxcutter_prometheus']['node_exporter']['source'] = \
    'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-arm64.tar.gz'
end

include_recipe 'boxcutter_prometheus::node_exporter'
