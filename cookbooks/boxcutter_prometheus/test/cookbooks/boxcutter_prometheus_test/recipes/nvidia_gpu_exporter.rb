#
# Cookbook:: boxcutter_prometheus_test
# Recipe:: nvidia_gpu_exporter
#

# The deb package currently installs to /usr/lib/systemd/system/ instead of
# /etc/systemd/system/ which should be reserved for os packages, so don't
# bother with the current release packages.

# case node['kernel']['machine']
# when 'x86_64', 'amd64'
#   node.default['boxcutter_prometheus']['nvidia_gpu_exporter']['source'] = \
#     'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/utkuozdemir/nvidia_gpu_exporter/releases/download/v1.3.2/nvidia_gpu_exporter_1.3.2_linux_x86_64.tar.gz'
#   node.default['boxcutter_prometheus']['nvidia_gpu_exporter']['checksum'] = \
#     'bc10dd41356625d28d18bf4d34c181050fc5c4cf28beee8774846d0140adac5f'
#   node.default['boxcutter_prometheus']['nvidia_gpu_exporter']['creates'] = \
#     'nvidia_gpu_exporter_1.3.2_linux_x86_64'
# when 'aarch64', 'arm64'
#   node.default['boxcutter_prometheus']['nvidia_gpu_exporter']['source'] = \
#     'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/utkuozdemir/nvidia_gpu_exporter/releases/download/v1.3.2/nvidia_gpu_exporter_1.3.2_linux_arm64.tar.gz'
#   node.default['boxcutter_prometheus']['nvidia_gpu_exporter']['checksum'] = \
#     'a201b3eefe08b2b713ccc9d5a929e9353ecd0b94d2ff6001b32dd2549e722ad5'
#   node.default['boxcutter_prometheus']['nvidia_gpu_exporter']['creates'] =
#     'nvidia_gpu_exporter_1.3.2_linux_arm64'
# end

node.default['boxcutter_prometheus']['nvidia_gpu_exporter']['command_line_flags'] = {
  'web.listen-address' => ':9835',
}

include_recipe 'boxcutter_prometheus::nvidia_gpu_exporter'
