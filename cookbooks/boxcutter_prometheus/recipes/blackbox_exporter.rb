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

include_recipe 'boxcutter_prometheus::user'

boxcutter_prometheus_tarball 'blackbox_exporter' do
  source lazy { node['boxcutter_prometheus']['blackbox_exporter']['source'] }
  checksum lazy { node['boxcutter_prometheus']['blackbox_exporter']['checksum'] }
  creates lazy { node['boxcutter_prometheus']['blackbox_exporter']['creates'] }
end

directory '/etc/blackbox_exporter' do
  owner 'root'
  group 'root'
  mode '0755'
end

template '/etc/blackbox_exporter/blackbox.yml' do
  source 'blackbox_exporter/blackbox.yml.erb'
  owner 'root'
  group 'prometheus'
  mode '0644'
  notifies :reload, 'service[blackbox_exporter]'
end

template '/etc/systemd/system/blackbox_exporter.service' do
  source 'blackbox_exporter/blackbox_exporter.service.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'fb_systemd_reload[system instance]', :immediately
end

service 'blackbox_exporter' do
  action [:enable, :start]
  only_if { node['boxcutter_prometheus']['blackbox_exporter']['enable'] }
end

service 'disable blackbox_exporter' do
  service_name 'blackbox_exporter'
  action [:stop, :disable]
  not_if { node['boxcutter_prometheus']['blackbox_exporter']['enable'] }
end
