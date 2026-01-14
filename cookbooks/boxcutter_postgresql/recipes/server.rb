#
# Cookbook:: boxcutter_postgresql
# Recipe:: server
#
# Copyright:: 2025-present, Taylor.dev, LLC
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

include_recipe 'boxcutter_postgresql::common'

case node['platform']
when 'ubuntu'
  FB::Users.initialize_group(node, 'postgres')
  node.default['fb_users']['users']['postgres'] = {
    'gid' => 'postgres',
    'comment' => 'PostgreSQL administrator',
    'home' => '/var/lib/postgresql',
    'shell' => '/bin/bash',
    'action' => :add,
  }

  package 'postgresql-16' do
    action :upgrade
  end

  service 'postgresql' do
    supports :restart => true, :status => true, :reload => true
    action [:enable, :start]
    only_if { node['boxcutter_postgresql']['server']['enable'] }
  end

  service 'disable postgresql' do
    service_name 'postgresql'
    action [:enable, :start]
    action [:stop, :disable]
    not_if { node['boxcutter_postgresql']['server']['enable'] }
  end

  template '/etc/postgresql/16/main/postgresql.conf' do
    source 'postgresql.conf.erb'
    owner 'postgres'
    group 'postgres'
    mode '0600'
    notifies :reload, 'service[postgresql]', :immediately
  end

  template '/etc/postgresql/16/main/pg_hba.conf' do
    owner 'postgres'
    group 'postgres'
    mode '0600'
    notifies :reload, 'service[postgresql]', :immediately
  end
when 'centos'
  FB::Users.initialize_group(node, 'postgres')
  node.default['fb_users']['users']['postgres'] = {
    'gid' => 'postgres',
    'shell' => '/bin/bash',
    'home' => '/var/lib/pgsql',
    'action' => :add,
  }

  package 'postgresql16-server' do
    action :upgrade
  end

  execute '/usr/pgsql-16/bin/postgresql-16-setup initdb' do
    live_stream true
    creates '/var/lib/pgsql/16/data/pg_hba.conf'
    not_if { ::File.exist?('/var/lib/pgsql/16/data/PG_VERSION') }
  end

  service 'postgresql' do
    service_name 'postgresql-16.service'
    supports :restart => true, :status => true, :reload => true
    action [:enable, :start]
    only_if { node['boxcutter_postgresql']['server']['enable'] }
  end

  service 'disable postgresql' do
    service_name 'postgresql-16.service'
    action [:enable, :start]
    action [:stop, :disable]
    not_if { node['boxcutter_postgresql']['server']['enable'] }
  end

  template '/var/lib/pgsql/16/data/postgresql.conf' do
    source 'postgresql.conf.erb'
    owner 'postgres'
    group 'postgres'
    mode '0600'
    notifies :reload, 'service[postgresql]', :immediately
  end

  template '/var/lib/pgsql/16/data/pg_hba.conf' do
    owner 'postgres'
    group 'postgres'
    mode '0600'
    notifies :reload, 'service[postgresql]', :immediately
  end
end
