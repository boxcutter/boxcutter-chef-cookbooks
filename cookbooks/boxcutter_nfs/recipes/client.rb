#
# Cookbook:: boxcutter_nfs
# Recipe:: client
#
# Copyright:: 2024, Boxcutter
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0 #
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# rubocop:disable Style/IdenticalConditionalBranches
if node.ubuntu?
  package 'nfs-common' do
    action :upgrade
  end

  template '/etc/idmapd.conf' do
    source 'idmapd.conf.erb'
    owner node.root_user
    group node.root_group
    mode '0644'
  end

  service 'rpcbind' do
    action [:enable, :start]
  end

  service 'rpc-statd' do
    action [:enable, :start]
  end
else
  package 'nfs-utils' do
    action :upgrade
  end

  template '/etc/idmapd.conf' do
    source 'idmapd.conf.erb'
    owner node.root_user
    group node.root_group
    mode '0644'
  end

  service 'rpcbind' do
    action [:enable, :start]
  end

  service 'rpc-statd' do
    action [:enable, :start]
  end
end
