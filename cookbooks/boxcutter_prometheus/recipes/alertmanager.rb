#
# Cookbook:: boxcutter_prometheus
# Recipe:: alertmanager
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

case node['kernel']['machine']
when 'x86_64', 'amd64'
  source = 'https://github.com/prometheus/alertmanager/releases/download/v0.27.0/alertmanager-0.27.0.linux-amd64.tar.gz'
  checksum = '23c3f5a3c73de91dbaec419f3c492bef636deb02680808e5d842e6553aa16074'
  creates = 'alertmanager-0.27.0.linux-amd64'
when 'aarch64', 'arm64'
  source = 'https://github.com/prometheus/alertmanager/releases/download/v0.27.0/alertmanager-0.27.0.linux-arm64.tar.gz'
  checksum = 'a754304b682cec61f4bd5cfc029b451a30134554b3a2f21a9c487e12814ff8f3'
  creates = 'alertmanager-0.27.0.linux-arm64'
end

tmp_path = ::File.join(Chef::Config[:file_cache_path], ::File.basename(source))

remote_file tmp_path do
  source source
  checksum checksum
end

install_path = '/opt/alertmanager'

directory install_path do
  owner node.root_user
  group node.root_user
  mode '0755'
end

execute 'extract alertmanager' do
  command <<-BASH
    tar --extract --directory #{install_path} --file #{tmp_path}
  BASH
  creates "#{install_path}/#{creates}"
end

# alertmanager_config_dir: /etc/alertmanager
# alertmanager_db_dir: /var/lib/alertmanager
