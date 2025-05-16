#
# Cookbook:: boxcutter_prometheus_test
# Recipe:: alertmanager
#

case node['kernel']['machine']
when 'x86_64', 'amd64'
  node.default['boxcutter_prometheus']['alertmanager']['source'] = \
    'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus/alertmanager/releases/download/v0.28.1/alertmanager-0.28.1.linux-amd64.tar.gz'
when 'aarch64', 'arm64'
  node.default['boxcutter_prometheus']['alertmanager']['source'] = \
    'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus/alertmanager/releases/download/v0.28.1/alertmanager-0.28.1.linux-arm64.tar.gz'
end

include_recipe 'boxcutter_prometheus::alertmanager'
