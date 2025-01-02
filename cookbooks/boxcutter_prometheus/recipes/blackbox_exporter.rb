#
# Cookbook:: boxcutter_prometheus
# Recipe:: blackbox_exporter
#
# Copyright:: 2024, Boxcutter
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

blackbox_exporter_user = 'blackbox_exporter'
blackbox_exporter_group = 'blackbox_exporter'

FB::Users.initialize_group(node, blackbox_exporter_group)

node.default['fb_users']['users'][blackbox_exporter_user] = {
  'group' => blackbox_exporter_group,
  'shell' => '/sbin/nologin',
  'action' => :add,
}

case node['kernel']['machine']
when 'x86_64', 'amd64'
  source = 'https://github.com/prometheus/blackbox_exporter/releases/download/v0.25.0/blackbox_exporter-0.25.0.linux-amd64.tar.gz'
  checksum = 'c651ced6405c5e0cd292a400f47ae9b34f431f16c7bb098afbcd38f710144640'
  creates = 'blackbox_exporter-0.25.0.linux-amd64'
when 'aarch64', 'arm64'
  source = 'https://github.com/prometheus/blackbox_exporter/releases/download/v0.25.0/blackbox_exporter-0.25.0.linux-arm64.tar.gz'
  checksum = '46ec5a54a41dc1ea8a8cecee637e117de4807d3b0976482a16596e82e79ac484'
  creates = 'blackbox_exporter-0.25.0.linux-arm64'
end

tmp_path = ::File.join(Chef::Config[:file_cache_path], ::File.basename(source))

remote_file tmp_path do
  source source
  checksum checksum
end

install_path = '/opt/blackbox_exporter'

directory install_path do
  owner node.root_user
  group node.root_user
  mode '0755'
end

execute 'extract blackbox_exporter' do
  command <<-BASH
    tar --extract --directory #{install_path} --file #{tmp_path}
  BASH
  creates "#{install_path}/#{creates}"
end

# blackbox_exporter_config_dir: /etc/blackbox_exporter
