#
# Cookbook:: boxcutter_prometheus
# Recipe:: postgres_exporter
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

include_recipe 'boxcutter_prometheus::user'

boxcutter_prometheus_tarball 'postgres_exporter' do
  source lazy { node['boxcutter_prometheus']['postgres_exporter']['source'] }
  checksum lazy { node['boxcutter_prometheus']['postgres_exporter']['checksum'] }
  creates lazy { node['boxcutter_prometheus']['postgres_exporter']['creates'] }
end

directory '/etc/postgres_exporter' do
  owner 'root'
  group 'root'
  mode '0755'
end

template '/etc/postgres_exporter/postgres_exporter.yml' do
  owner 'root'
  group 'prometheus'
  mode '0644'
  notifies :reload, 'service[postgres_exporter.service]'
end

template '/etc/systemd/system/postgres_exporter.service' do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'fb_systemd_reload[system instance]', :immediately
  notifies :restart, 'service[postgres_exporter.service]'
end

service 'postgres_exporter.service' do
  action [:enable, :start]
end
