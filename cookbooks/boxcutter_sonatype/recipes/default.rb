#
# Cookbook:: boxcutter_sonatype
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

directory '/opt/sonatype' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

version = 'nexus-3.70.1-02'
url = 'https://download.sonatype.com/nexus/3/nexus-3.70.1-02-java11-unix.tar.gz'
checksum = '38c6f81d78c2f6ae461f491d9321d36e98ff2e19eee365270d9bc92377d36588'

tmp_path = ::File.join(Chef::Config[:file_cache_path], ::File.basename(url))

remote_file tmp_path do
  source url
  checksum checksum
end

path = ::File.join('/opt/sonatype', version)

execute 'extract nexus' do
  command <<-BASH
    tar --exclude='sonatype-work*' --extract --directory '/opt/sonatype' --file #{tmp_path}
    chown -R nexus:nexus '/opt/sonatype/nexus-3.70.1-02'
  BASH
  creates '/opt/sonatype/nexus-3.70.1-02/bin/nexus'
end

link '/opt/sonatype/nexus' do
  to path.to_s
end

directory '/opt/sonatype/nexus/nexus3' do
  recursive true
  action :delete
end

directory '/nexus-data' do
  owner 'nexus'
  group 'nexus'
  mode '0755'
  recursive true
  action :create
 end

directory '/nexus-data/etc' do
  owner 'nexus'
  group 'nexus'
  mode '0755'
  recursive true
  action :create
 end

directory '/nexus-data/log' do
  owner 'nexus'
  group 'nexus'
  mode '0755'
  recursive true
  action :create
end

directory '/nexus-data/tmp' do
  owner 'nexus'
  group 'nexus'
  mode '0755'
  recursive true
  action :create
end

directory '/opt/sonatype/sonatype-work' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

link '/opt/sonatype/sonatype-work/nexus3' do
  to '/nexus-data'
  owner 'root'
  group 'root'
end

node.default['boxcutter_java']['sdkman'] = {
  '/opt/sonatype/nexus/.sdkman' => {
    'user' => 'nexus',
    'group' => 'nexus',
    'candidates' => {
      'java' => '11.0.24-tem',
    },
  },
}

FB::Users.initialize_group(node, 'nexus')
node.default['fb_users']['users']['nexus'] = {
  'home' => '/opt/sonatype/nexus',
  'gid' => 'nexus',
  'shell' => '/bin/bash',
  'manage_home' => false,
  'action' => :add,
}

include_recipe 'boxcutter_java::default'

template '/opt/sonatype/start-nexus-repository-manager.sh' do
  source 'start-nexus-repository-manager.sh.erb'
  owner 'root'
  group 'root'
  mode '0755'
end

systemd_unit 'nexus-repository-manager.service' do
  content <<-EOU.gsub(/^\s+/, '')
  [Unit]
  Description=Nexus Repository Manager service
  After=network.target
  [Service]
  Type=simple
  LimitNOFILE=65536
  ExecStart=/opt/sonatype/start-nexus-repository-manager.sh
  User=nexus
  Restart=on-failure
  StartLimitInterval=30min
  StartLimitBurst=2
  [Install]
  WantedBy=multi-user.target
  EOU
  action [:create, :enable, :start]
end
