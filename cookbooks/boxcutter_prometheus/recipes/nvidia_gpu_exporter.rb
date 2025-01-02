#
# Cookbook:: boxcutter_prometheus
# Recipe:: nvidia_gpu_exporter
#
# Copyright:: 2025, Boxcutter
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

nvidia_gpu_exporter_user = 'nvidia_gpu_exporter'
nvidia_gpu_exporter_group = 'nvidia_gpu_exporter'

FB::Users.initialize_group(node, nvidia_gpu_exporter_group)

node.default['fb_users']['users'][nvidia_gpu_exporter_user] = {
  'group' => nvidia_gpu_exporter_group,
  'shell' => '/sbin/nologin',
  'action' => :add,
}

case node['kernel']['machine']
when 'x86_64', 'amd64'
  source = 'https://github.com/utkuozdemir/nvidia_gpu_exporter/releases/download/v1.2.1/nvidia_gpu_exporter_1.2.1_linux_x86_64.tar.gz'
  checksum = 'b9e506e0d3a2ba79747e78802c2e238ed09cc04872138dad2f6cfde3c4a64061'
  creates = 'nvidia_gpu_exporter_1.2.1_linux_x86_64'
when 'aarch64', 'arm64'
  source = 'https://github.com/utkuozdemir/nvidia_gpu_exporter/releases/download/v1.2.1/nvidia_gpu_exporter_1.2.1_linux_arm64.tar.gz'
  checksum = '2b33e3472491d77eadf098ec04d53c5fad2ef2a0861f136872f4d4e42069408b'
  creates = 'nvidia_gpu_exporter_1.2.1_linux_arm64'
end

tmp_path = ::File.join(Chef::Config[:file_cache_path], ::File.basename(source))

remote_file tmp_path do
  source source
  checksum checksum
end

install_path = '/opt/nvidia_gpu_exporter'

directory install_path do
  owner node.root_user
  group node.root_user
  mode '0755'
end

execute 'extract nvidia_gpu_exporter' do
  command <<-BASH
    tar --extract --directory #{install_path} --file #{tmp_path}
  BASH
  creates "#{install_path}/#{creates}"
end

link "#{install_path}/latest" do
  to "#{install_path}/#{creates}"
end

systemd_unit 'nvidia_gpu_exporter.service' do
  content <<~EOU
  [Unit]
  Description=Nvidia GPU Exporter
  After=network-online.target

  [Service]
  Type=simple

  User=#{nvidia_gpu_exporter_user}
  Group=#{nvidia_gpu_exporter_group}

  ExecStart=/opt/node_exporter/latest/nvidia_gpu_exporter

  SyslogIdentifier=nvidia_gpu_exporter

  Restart=always
  RestartSec=1

  [Install]
  WantedBy=multi-user.target
  EOU

  action [:create, :enable, :start]
end
