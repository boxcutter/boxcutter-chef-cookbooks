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

include_recipe 'boxcutter_prometheus::user'

boxcutter_prometheus_tarball 'alertmanager' do
  source lazy { node['boxcutter_prometheus']['alertmanager']['source'] }
  checksum lazy { node['boxcutter_prometheus']['alertmanager']['checksum'] }
  creates lazy { node['boxcutter_prometheus']['alertmanager']['creates'] }
end

directory '/etc/alertmanager' do
  owner 'root'
  group 'root'
  mode '0755'
end

directory '/var/lib/alertmanager' do
  owner 'prometheus'
  group 'prometheus'
  mode '0755'
end

template '/etc/alertmanager/alertmanager.yml' do
  source 'alertmanager/alertmanager.yml.erb'
  owner 'root'
  group 'prometheus'
  mode '0644'
  notifies :reload, 'service[alertmanager]'
end

template '/etc/systemd/system/alertmanager.service' do
  source 'alertmanager/alertmanager.service.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'fb_systemd_reload[system instance]', :immediately
end

service 'alertmanager' do
  action [:enable, :start]
  only_if { node['boxcutter_prometheus']['alertmanager']['enable'] }
end

service 'disable alertmanager' do
  service_name 'alertmanager'
  action [:stop, :disable]
  not_if { node['boxcutter_prometheus']['alertmanager']['enable'] }
end
