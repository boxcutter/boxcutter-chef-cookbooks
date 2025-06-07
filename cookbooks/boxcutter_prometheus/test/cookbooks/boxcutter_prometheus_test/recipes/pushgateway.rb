#
# Cookbook:: boxcutter_prometheus_test
# Recipe:: pushgateway
#

# case node['kernel']['machine']
# when 'x86_64', 'amd64'
#   node.default['boxcutter_prometheus']['pushgateway']['source'] = \
#     'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus/pushgateway/releases/download/v1.11.1/pushgateway-1.11.1.linux-amd64.tar.gz'
#   node.default['boxcutter_prometheus']['pushgateway']['checksum'] = \
#     '6ce6ffab84d0d71195036326640295c02165462abd12b8092b0fa93188f5ee37'
#   node.default['boxcutter_prometheus']['pushgateway']['creates'] = \
#     'pushgateway-1.11.1.linux-amd64'
# when 'aarch64', 'arm64'
#   node.default['boxcutter_prometheus']['pushgateway']['source'] = \
#     'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus/pushgateway/releases/download/v1.11.1/pushgateway-1.11.1.linux-arm64.tar.gz'
#   node.default['boxcutter_prometheus']['pushgateway']['checksum'] = \
#     'b6dc1c1c46d1137e5eda253f6291247e39330d3065a839857b947e59b4f3e64b'
#   node.default['boxcutter_prometheus']['pushgateway']['creates'] = \
#     'pushgateway-1.11.1.linux-arm64'
# end

node.default['boxcutter_prometheus']['pushgateway']['command_line_flags'] = {
  'web.listen-address' => '0.0.0.0:9091',
}

include_recipe 'boxcutter_prometheus::pushgateway'
