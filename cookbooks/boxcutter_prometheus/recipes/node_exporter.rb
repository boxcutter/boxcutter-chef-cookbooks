#
# Cookbook:: boxcutter_prometheus
# Recipe:: node_exporter
#
# Copyright:: 2024-present, Taylor.dev, LLC
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

# Port 9100 is the default node exporter port
node.default['fb_iptables']['filter']['INPUT']['rules']['node_exporter'] = {
  'rule' => '-p tcp --dport 9100 -j ACCEPT',
}

include_recipe 'boxcutter_prometheus::user'

boxcutter_prometheus_tarball 'node_exporter' do
  source lazy { node['boxcutter_prometheus']['node_exporter']['source'] }
  checksum lazy { node['boxcutter_prometheus']['node_exporter']['checksum'] }
  creates lazy { node['boxcutter_prometheus']['node_exporter']['creates'] }
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

template '/etc/systemd/system/node_exporter.service' do
  source 'node_exporter/node_exporter.service.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'fb_systemd_reload[system instance]', :immediately
  notifies :restart, 'service[node_exporter]'
end

service 'node_exporter' do
  action [:enable, :start]
  only_if { node['boxcutter_prometheus']['node_exporter']['enable'] }
end

service 'disable node_exporter' do
  service_name 'node_exporter'
  action [:disable, :stop]
  not_if { node['boxcutter_prometheus']['node_exporter']['enable'] }
end
