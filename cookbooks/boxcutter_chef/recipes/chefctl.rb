#
# Cookbook:: boxcutter_chef
# Recipe:: chefctl
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

cookbook_file '/usr/local/sbin/chefctl.rb' do
  source 'chefctl/chefctl.rb'
  owner 'root'
  group 'root'
  mode '0755'
end

link '/usr/local/sbin/chefctl' do
  to '/usr/local/sbin/chefctl.rb'
end

cookbook_file '/etc/chefctl-config.rb' do
  source 'chefctl/chefctl-config.rb'
  owner 'root'
  group 'root'
  mode '0644'
end

cookbook_file '/etc/chef/chefctl_hooks.rb' do
  source 'chefctl/chefctl_hooks.rb'
  owner 'root'
  group 'root'
  mode '0644'
end