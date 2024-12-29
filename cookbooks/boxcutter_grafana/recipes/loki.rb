#
# Cookbook:: boxcutter_grafana
# Recipe:: loki
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

node.default['fb_users']['users']['loki'] = {
  'gid' => 'nogroup',
  'home' => '/nonexistent',
  'shell' => '/bin/false',
  'action' => :add,
}

include_recipe '::common'

package 'loki' do
  action :upgrade
end

template '/etc/loki/config.yml' do
  source 'loki-config.yml.erb'
  owner node.root_user
  group node.root_group
  mode '0644'
  notifies :restart, 'service[loki]'
end

service 'loki' do
  action [:start, :enable]
end
