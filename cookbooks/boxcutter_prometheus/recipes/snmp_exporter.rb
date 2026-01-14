#
# Cookbook:: boxcutter_prometheus
# Recipe:: snmp_exporter
#
# Copyright:: 2025-present, Taylor.dev, LLC
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

include_recipe 'boxcutter_prometheus::user'

boxcutter_prometheus_tarball 'snmp_exporter' do
  source lazy { node['boxcutter_prometheus']['snmp_exporter']['source'] }
  checksum lazy { node['boxcutter_prometheus']['snmp_exporter']['checksum'] }
  creates lazy { node['boxcutter_prometheus']['snmp_exporter']['creates'] }
end

directory '/etc/snmp_exporter' do
  owner 'root'
  group 'root'
  mode '0755'
end

template '/etc/snmp_exporter/snmp.yml' do
  source 'snmp_exporter/snmp.yml.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[snmp_exporter]'
end

template '/etc/systemd/system/snmp_exporter.service' do
  source 'snmp_exporter/snmp_exporter.service.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'fb_systemd_reload[system instance]', :immediately
  notifies :restart, 'service[snmp_exporter]'
end

service 'snmp_exporter' do
  action [:enable, :start]
  only_if { node['boxcutter_prometheus']['snmp_exporter']['enable'] }
end

service 'disable snmp_exporter' do
  service_name 'snmp_exporter'
  action [:disable, :stop]
  not_if { node['boxcutter_prometheus']['snmp_exporter']['enable'] }
end
