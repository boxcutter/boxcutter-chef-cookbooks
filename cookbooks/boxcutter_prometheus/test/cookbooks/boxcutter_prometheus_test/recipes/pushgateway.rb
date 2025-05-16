#
# Cookbook:: boxcutter_prometheus_test
# Recipe:: pushgateway
#

case node['kernel']['machine']
when 'x86_64', 'amd64'
  node.default['boxcutter_prometheus']['pushgateway']['source'] = \
    'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus/pushgateway/releases/download/v1.11.1/pushgateway-1.11.1.linux-amd64.tar.gz'
when 'aarch64', 'arm64'
  node.default['boxcutter_prometheus']['pushgateway']['source'] = \
    'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus/pushgateway/releases/download/v1.11.1/pushgateway-1.11.1.linux-arm64.tar.gz'
end

include_recipe 'boxcutter_prometheus::pushgateway'
