#
# Cookbook:: boxcutter_robot
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

nfs_client_hosts = %w{
  nfs-client-centos-stream-9
  nfs-client-ubuntu-2204
}.include?(node['hostname'])

if nfs_client_hosts
  node.default['fb_iptables']['filter']['INPUT']['rules']['nfs server'] = {
    'rules' => [
      '-p tcp --dport 2049 -j ACCEPT',
      '-p udp --dport 2049 -j ACCEPT',
    ],
  }

  directory '/mnt' do
    owner node.root_user
    group node.root_group
    mode '0755'
  end

  directory '/mnt/server' do
    owner 'nobody'
    group node.ubuntu? ? 'nogroup' : 'nobody'
    mode '0777'
  end

  include_recipe 'boxcutter_nfs::client'

  node.default['fb_fstab']['mounts'][''] = {
    'device' => '10.63.46.196:/var/nfs/general',
    'mount_point' => '/mnt/server',
    'type' => 'nfs',
  }
end
