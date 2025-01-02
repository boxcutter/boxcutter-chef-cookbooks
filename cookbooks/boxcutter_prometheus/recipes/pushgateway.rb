#
# Cookbook:: boxcutter_prometheus
# Recipe:: pushgateway
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

pushgateway_user = 'pushgateway'
pushgateway_group = 'pushgateway'

FB::Users.initialize_group(node, pushgateway_group)

node.default['fb_users']['users'][pushgateway_user] = {
  'group' => pushgateway_group,
  'shell' => '/sbin/nologin',
  'action' => :add,
}

case node['kernel']['machine']
when 'x86_64', 'amd64'
  source = 'https://github.com/prometheus/pushgateway/releases/download/v1.10.0/pushgateway-1.10.0.linux-amd64.tar.gz'
  checksum = 'e2310c978da19362f2c7f91668550fdbbbb7421f7dfc8eb81a927e017f7b8d17'
  creates = 'pushgateway-1.10.0.linux-amd64'
when 'aarch64', 'arm64'
  source = 'https://github.com/prometheus/pushgateway/releases/download/v1.10.0/pushgateway-1.10.0.linux-arm64.tar.gz'
  checksum = 'eca6227623edbd8c7a30c2d7974f1516c51945e32508e0df1b9f301f74b88f68'
  creates = 'pushgateway-1.10.0.linux-arm64'
end

tmp_path = ::File.join(Chef::Config[:file_cache_path], ::File.basename(source))

remote_file tmp_path do
  source source
  checksum checksum
end

install_path = '/opt/pushgateway'

directory install_path do
  owner node.root_user
  group node.root_user
  mode '0755'
end

execute 'extract pushgateway' do
  command <<-BASH
    tar --extract --directory #{install_path} --file #{tmp_path}
  BASH
  creates "#{install_path}/#{creates}"
end

link "#{install_path}/latest" do
  to "#{install_path}/#{creates}"
end

systemd_unit 'pushgateway.service' do
  content <<~EOU
  [Unit]
  Description=Prometheus pushgateway
  After=network-online.target

  [Service]
  Type=simple
  User=#{pushgateway_user}
  Group=#{pushgateway_group}
  ExecStart=/opt/pushgateway/latest/pushgateway
  ExecReload=/bin/kill -HUP $MAINPID
  KillMode=process
  Restart=always

  [Install]
  WantedBy=multi-user.target
  EOU

  action [:create, :enable, :start]
end
