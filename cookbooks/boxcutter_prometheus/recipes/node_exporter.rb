#
# Cookbook:: boxcutter_prometheus
# Recipe:: node_exporter
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

node_exporter_user = 'node_exporter'
node_exporter_group = 'node_exporter'

FB::Users.initialize_group(node, node_exporter_group)

node.default['fb_users']['users'][node_exporter_user] = {
  'group' => node_exporter_group,
  'shell' => '/sbin/nologin',
  'action' => :add,
}

case node['kernel']['machine']
when 'x86_64', 'amd64'
  source = 'https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz'
  checksum = '6809dd0b3ec45fd6e992c19071d6b5253aed3ead7bf0686885a51d85c6643c66'
  creates = 'node_exporter-1.8.2.linux-amd64'
when 'aarch64', 'arm64'
  source = 'https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-arm64.tar.gz'
  checksum = '627382b9723c642411c33f48861134ebe893e70a63bcc8b3fc0619cd0bfac4be'
  creates = 'node_exporter-1.8.2.linux-arm64'
end

tmp_path = ::File.join(Chef::Config[:file_cache_path], ::File.basename(source))

remote_file tmp_path do
  source source
  checksum checksum
end

install_path = '/opt/node_exporter'

directory install_path do
  owner node.root_user
  group node.root_user
  mode '0755'
end

execute 'extract node_exporter' do
  command <<-BASH
    tar --extract --directory #{install_path} --file #{tmp_path}
  BASH
  creates "#{install_path}/#{creates}"
end

link "#{install_path}/latest" do
  to "#{install_path}/#{creates}"
end

%w{
  /var/lib/node_exporter
  /var/lib/node_exporter/textfile
}.each do |dir|
  directory dir do
    owner 'root'
    group 'root'
    mode '0755'
  end
end

# node_exporter_config_dir: "/etc/node_exporter"
# node_exporter_textfile_dir: "/var/lib/node_exporter"

systemd_unit 'node_exporter.service' do
  content <<~EOU
  [Unit]
  Description=Prometheus Node Exporter
  After=network-online.target

  [Service]
  Type=simple
  User=#{node_exporter_user}
  Group=#{node_exporter_group}
  ExecStart=/opt/node_exporter/latest/node_exporter \
    --collector.systemd \
    --collector.processes \
    --no-collector.infiniband \
    --no-collector.nfs \
    --collector.textfile \
    --collector.textfile.directory="/var/lib/node_exporter/textfile" \
    --web.listen-address="localhost:9100"
  ExecReload=/bin/kill -HUP $MAINPID
  KillMode=process
  Restart=always

  [Install]
  WantedBy=multi-user.target
  EOU

  action [:create, :enable, :start]
end
