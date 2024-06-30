#
# Cookbook:: boxcutter_nfs
# Recipe:: server
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

package 'nfs-kernel-server' do
  action :upgrade
end

template '/etc/exports' do
  source 'exports.erb'
  owner node.root_user
  group node.root_group
  mode '0644'
  notifies :run, 'execute[export all filesystems]'
end

template '/etc/default/nfs-kernel-server' do
  source 'nfs-kernel-server.erb'
  owner node.root_user
  group node.root_group
  mode '0644'
  notifies :restart, 'service[nfs-kernel-server]'
end

service 'nfs-kernel-server' do
  action [:enable, :start]
  notifies :run, 'execute[export all filesystems]'
end

execute 'export all filesystems' do
  command 'exportfs -r'
  action :nothing
end
