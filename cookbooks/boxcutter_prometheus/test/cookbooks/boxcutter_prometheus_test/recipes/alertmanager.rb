#
# Cookbook:: boxcutter_prometheus_test
# Recipe:: alertmanager
#

# case node['kernel']['machine']
# when 'x86_64', 'amd64'
#   node.default['boxcutter_prometheus']['alertmanager']['source'] = \
#     'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus/alertmanager/releases/download/v0.28.1/alertmanager-0.28.1.linux-amd64.tar.gz'
#   node.default['boxcutter_prometheus']['alertmanager']['checksum'] = \
#     '5ac7ab5e4b8ee5ce4d8fb0988f9cb275efcc3f181b4b408179fafee121693311'
#   node.default['boxcutter_prometheus']['alertmanager']['creates'] = \
#     'alertmanager-0.28.1.linux-amd64'
# when 'aarch64', 'arm64'
#   node.default['boxcutter_prometheus']['alertmanager']['source'] = \
#     'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus/alertmanager/releases/download/v0.28.1/alertmanager-0.28.1.linux-arm64.tar.gz'
#   node.default['boxcutter_prometheus']['alertmanager']['checksum'] = \
#     'd8832540e5b9f613d2fd759e31d603173b9c61cc7bb5e3bc7ae2f12038b1ce4f'
#   node.default['boxcutter_prometheus']['alertmanager']['creates'] = \
#     'alertmanager-0.28.1.linux-arm64'
# end

node.default['boxcutter_prometheus']['alertmanager']['command_line_flags'] = {
  'storage.path' => '/var/lib/alertmanager/data',
  'web.listen-address' => ':9093',
}

include_recipe 'boxcutter_prometheus::alertmanager'
