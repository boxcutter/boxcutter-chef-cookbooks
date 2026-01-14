#
# Cookbook:: boxcutter_nfs
# Recipe:: server
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

# rubocop:disable Style/IdenticalConditionalBranches
if node.ubuntu?
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

  if node['platform_version'].to_f >= 22.04
    template '/etc/nfs.conf' do
      source 'nfs.conf.erb'
      owner node.root_user
      group node.root_group
      mode '0644'
      notifies :restart, 'service[nfs-kernel-server]'
    end
  else
    # Prior to Ubuntu 20.04 /etc/default was used for config
    template '/etc/default/nfs-kernel-server' do
      source 'nfs-kernel-server.erb'
      owner node.root_user
      group node.root_group
      mode '0644'
      notifies :restart, 'service[nfs-kernel-server]'
    end
  end

  service 'nfs-kernel-server' do
    action [:enable, :start]
    notifies :run, 'execute[export all filesystems]'
  end

  execute 'export all filesystems' do
    command 'exportfs -r'
    action :nothing
  end
else
  package 'nfs-utils' do
    action :upgrade
  end

  template '/etc/exports' do
    source 'exports.erb'
    owner node.root_user
    group node.root_group
    mode '0644'
    notifies :run, 'execute[export all filesystems]'
  end

  # /etc/nfs.conf - Main configuration file for NFS services
  # /etc/sysconfig/nfs - Configuration file for NFS service environment variables
  template '/etc/nfs.conf' do
    source 'nfs.conf.erb'
    owner node.root_user
    group node.root_group
    mode '0644'
    notifies :restart, 'service[nfs-server]'
  end

  service 'nfs-server' do
    action [:enable, :start]
  end

  execute 'export all filesystems' do
    command 'exportfs -r'
    action :nothing
  end
end
