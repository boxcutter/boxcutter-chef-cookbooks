#
# Cookbook:: boxcutter_prometheus_test
# Recipe:: nvidia_gpu_exporter
#

# The deb package currently installs to /usr/lib/systemd/system/ instead of
# /etc/systemd/system/ which should be reserved for os packages, so don't
# bother with the current release packages.

case node['kernel']['machine']
when 'x86_64', 'amd64'
  node.default['boxcutter_prometheus']['nvidia_gpu_exporter']['source'] = \
    'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/utkuozdemir/nvidia_gpu_exporter/releases/download/v1.3.2/nvidia_gpu_exporter_1.3.2_linux_x86_64.tar.gz'
when 'aarch64', 'arm64'
  node.default['boxcutter_prometheus']['nvidia_gpu_exporter']['source'] = \
    'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/utkuozdemir/nvidia_gpu_exporter/releases/download/v1.3.2/nvidia_gpu_exporter_1.3.2_linux_arm64.tar.gz'
end

include_recipe 'boxcutter_prometheus::nvidia_gpu_exporter'
