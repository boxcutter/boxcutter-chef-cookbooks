#
# Cookbook:: boxcutter_tailscale
# Recipe:: default
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

node.default['fb_iptables']['dynamic_chains']['filter']['ts-input'] = [
  'INPUT',
]
node.default['fb_iptables']['dynamic_chains']['filter']['ts-forward'] = [
  'FORWARD',
]

include_recipe 'boxcutter_tailscale::packages'

service 'tailscaled' do
  supports :status => true, :restart => true
  action [:start, :enable]
  only_if { node['boxcutter_tailscale']['enable'] }
end

service 'disable tailscaled' do
  service_name 'tailscaled'
  supports :status => true, :restart => true
  action [:stop, :disable]
  not_if { node['boxcutter_tailscale']['enable'] }
end

boxcutter_tailscale 'default' do
  hostname lazy { node['boxcutter_tailscale']['hostname'] }
  api_base_url lazy { node['boxcutter_tailscale']['api_base_url'] }
  tailnet lazy { node['boxcutter_tailscale']['tailnet'] }
  ephemeral lazy { node['boxcutter_tailscale']['ephemeral'] }
  tags lazy { node['boxcutter_tailscale']['tags'] }
  use_tailscale_dns lazy { node['boxcutter_tailscale']['use_tailscale_dns'] }
  shields_up lazy { node['boxcutter_tailscale']['shields_up'] }
end
