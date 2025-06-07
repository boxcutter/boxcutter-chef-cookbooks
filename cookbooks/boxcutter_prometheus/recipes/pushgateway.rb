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

include_recipe 'boxcutter_prometheus::user'

boxcutter_prometheus_tarball 'pushgateway' do
  source lazy { node['boxcutter_prometheus']['pushgateway']['source'] }
  checksum lazy { node['boxcutter_prometheus']['pushgateway']['checksum'] }
  creates lazy { node['boxcutter_prometheus']['pushgateway']['creates'] }
end

template '/etc/systemd/system/pushgateway.service' do
  source 'pushgateway/pushgateway.service.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'fb_systemd_reload[system instance]', :immediately
  notifies :restart, 'service[pushgateway]'
end

service 'pushgateway' do
  action [:enable, :start]
  only_if { node['boxcutter_prometheus']['pushgateway']['enable'] }
end

service 'disable pushgateway' do
  service_name 'pushgateway'
  action [:disable, :stop]
  not_if { node['boxcutter_prometheus']['pushgateway']['enable'] }
end
