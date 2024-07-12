#
# Cookbook:: boxcutter_backhaul
# Recipe:: default
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

nfs_server_hosts = %w{
  nfs-server-centos-stream-9
  nfs-server-ubuntu-2204
}.include?(node['hostname'])

if nfs_server_hosts
  node.default['fb_iptables']['filter']['INPUT']['rules']['nfs server'] = {
    'rules' => [
      '-p tcp --dport 2049 -j ACCEPT',
      '-p udp --dport 2049 -j ACCEPT',
    ],
  }

  directory '/var/nfs' do
    owner node.root_user
    group node.root_group
    mode '0755'
  end

  directory '/var/nfs/general' do
    owner 'nobody'
    group node.ubuntu? ? 'nogroup' : 'nobody'
    mode '0777'
  end

  node.default['boxcutter_nfs']['server']['exports']['/var/nfs/general'] = %w{
    *(rw,sync,no_subtree_check,insecure)
  }

  include_recipe 'boxcutter_nfs::server'
end

artifactory_hosts = %w{
  crake-artifactory-playpen
  hq0-rt01
}.include?(node['hostname'])

if artifactory_hosts
  include_recipe 'boxcutter_jfrog::container_registry_docker'
end
