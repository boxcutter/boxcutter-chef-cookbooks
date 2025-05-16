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

include_recipe 'boxcutter_prometheus::user'

boxcutter_prometheus_tarball 'prometheus' do
  source lazy { node['boxcutter_prometheus']['prometheus']['source'] }
  checksum lazy { node['boxcutter_prometheus']['prometheus']['checksum'] }
  creates lazy { node['boxcutter_prometheus']['prometheus']['creates'] }
end

directory '/etc/prometheus' do
  owner 'prometheus'
  group 'prometheus'
  mode '0755'
end

template '/etc/prometheus/alerting_rules.yml' do
  owner 'prometheus'
  group 'prometheus'
  mode '0644'
  verify '/opt/prometheus/latest/promtool check rules %{path}'
  only_if do
    node['boxcutter_prometheus']['prometheus']['alerting_rules'].is_a?(Hash) \
      && !node['boxcutter_prometheus']['prometheus']['alerting_rules'].empty?
  end
end

template '/etc/prometheus/recording_rules.yml' do
  owner 'prometheus'
  group 'prometheus'
  mode '0644'
  verify '/opt/prometheus/latest/promtool check rules %{path}'
  only_if do
    node['boxcutter_prometheus']['prometheus']['recording_rules'].is_a?(Hash) \
      && !node['boxcutter_prometheus']['prometheus']['recording_rules'].empty?
  end
end

template '/etc/prometheus/prometheus.yml' do
  owner 'prometheus'
  group 'prometheus'
  mode '0644'
  verify '/opt/prometheus/latest/promtool check config %{path}'
  notifies :reload, 'service[prometheus.service]'
end

directory '/var/lib/prometheus' do
  owner 'prometheus'
  group 'prometheus'
  mode '0755'
end

template '/etc/systemd/system/prometheus.service' do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'fb_systemd_reload[system instance]', :immediately
end

service 'prometheus.service' do
  action [:enable, :start]
end
