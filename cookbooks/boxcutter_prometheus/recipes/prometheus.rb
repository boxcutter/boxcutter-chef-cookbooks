#
# Cookbook:: boxcutter_prometheus
# Recipe:: prometheus
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

prometheus_user = 'prometheus'
prometheus_group = 'prometheus'

FB::Users.initialize_group(node, prometheus_group)

node.default['fb_users']['users'][prometheus_user] = {
  'group' => prometheus_group,
  'shell' => '/sbin/nologin',
  'action' => :add,
}

case node['kernel']['machine']
when 'x86_64', 'amd64'
  source = 'https://github.com/prometheus/prometheus/releases/download/v3.0.1/prometheus-3.0.1.linux-amd64.tar.gz'
  checksum = '43f6f228ef59e0c2f6994e489c5c76c6671553eaa99ded0aea1cd31366222916'
  creates = 'prometheus-3.0.1.linux-amd64'
when 'aarch64', 'arm64'
  source = 'https://github.com/prometheus/prometheus/releases/download/v3.0.1/prometheus-3.0.1.linux-arm64.tar.gz'
  checksum = '58e8d4f3ab633528fa784740409c529f4a434f8a0e3cf4d2f56e75ce2db69aa8'
  creates = 'prometheus-3.0.1.linux-arm64'
end

tmp_path = ::File.join(Chef::Config[:file_cache_path], ::File.basename(source))

remote_file tmp_path do
  source source
  checksum checksum
end

install_path = '/opt/prometheus'

directory install_path do
  owner node.root_user
  group node.root_user
  mode '0755'
end

execute 'extract prometheus' do
  command <<-BASH
    tar --extract --directory #{install_path} --file #{tmp_path}
  BASH
  creates "#{install_path}/#{creates}"
end

link "#{install_path}/latest" do
  to "#{install_path}/#{creates}"
end

directory '/etc/prometheus' do
  owner prometheus_user
  group prometheus_group
  mode '0755'
end

template '/etc/prometheus/prometheus.yml' do
  owner prometheus_user
  group prometheus_group
  mode '0644'
  verify '/opt/prometheus/latest/promtool check config %{path}'
  notifies :reload, 'systemd_unit[prometheus.service]'
end

# /opt/prometheus/latest/promtool check config /etc/prometheus/prometheus.yml

directory '/var/lib/prometheus' do
  owner prometheus_user
  group prometheus_group
  mode '0755'
end

systemd_unit 'prometheus.service' do
  content <<~EOU
  [Unit]
  Description=Prometheus Server
  Documentation=https://prometheus.io/docs/introduction/overview/
  After=network-online.target

  [Service]
  User=#{prometheus_user}
  Group=#{prometheus_group}
  Restart=on-failure
  ExecStart=/opt/prometheus/latest/prometheus \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/var/lib/prometheus/data \
    --storage.tsdb.retention.time=30d
  ExecReload=/bin/kill -HUP $MAINPID
  PIDFile=/var/run/prometheus.pid
  Restart=on-failure

  [Install]
  WantedBy=multi-user.target
  EOU

  action [:create, :enable, :start]
end
