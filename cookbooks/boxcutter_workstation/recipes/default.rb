#
# Cookbook:: boxcutter_workstation
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

workstation_hosts = %w{
  crake-stunt-ubuntu-desktop-2204
  crake-stunt-ubuntu-desktop-2404
  sfo2-ubuntu-desktop-2204
  sfo2-ubuntu-desktop-2404
}.include?(node['hostname'])

if workstation_hosts
  include_recipe 'boxcutter_ubuntu_desktop'
end

golang_dev_hosts = %w{
  crake-golang-dev
}.include?(node['hostname'])

if golang_dev_hosts
  node.default['fb_users']['users']['boxcutter'] = {
    'gid' => 'users',
    'home' => '/home/boxcutter',
    'shell' => '/bin/bash',
    'action' => :add,
  }

  node.default['fb_sudo']['users']['boxcutter']['admin'] =
    'ALL=(ALL:ALL) NOPASSWD: ALL'

  directory '/home/boxcutter/.bashrc.d' do
    owner 'boxcutter'
    group 'users'
    mode '0700'
  end

  file '/home/boxcutter/.bashrc.d/000.keep.bashrc' do
    owner 'boxcutter'
    group 'users'
    mode '0644'
  end

  template '/home/boxcutter/.bashrc' do
    source 'bashrc.erb'
    owner 'boxcutter'
    group 'users'
    mode '0644'
  end

  template '/home/boxcutter/.bashrc.d/100.golang.bashrc' do
    source 'golang.bashrc.erb'
    owner 'boxcutter'
    group 'users'
    mode '0700'
  end

  include_recipe 'boxcutter_golang'
end
