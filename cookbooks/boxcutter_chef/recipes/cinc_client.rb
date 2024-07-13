#
# Cookbook:: boxcutter_chef
# Recipe:: cinc_client
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

# kitchen-dokken volume mounts cinc in as /opt/cinc from a container image.
# Don't try to manage packages in this scenario.
if ::Pathname.new('/opt/cinc').mountpoint?
  node.default['boxcutter_chef']['cinc_client']['manage_packages'] = false
end

case node['platform']
when 'ubuntu'
  case node['kernel']['machine']
  when 'x86_64', 'amd64'
    package_info = value_for_platform(
      'ubuntu' => {
        '20.04' => {
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.5.0/ubuntu/20.04/cinc_18.5.0-1_amd64.deb',
          'checksum' => 'def7a65cda41fb378b0a14a310e880c677f9ebf40f960243894020e1c72420b8',
        },
        '22.04' => {
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.5.0/ubuntu/22.04/cinc_18.5.0-1_amd64.deb',
          'checksum' => 'e7a9bbcf112d0d523689c32230080b834f651d2ac4a4d5d38c1befe77de28148',
        },
        '24.04' => {
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.5.0/ubuntu/22.04/cinc_18.5.0-1_amd64.deb',
          'checksum' => 'e7a9bbcf112d0d523689c32230080b834f651d2ac4a4d5d38c1befe77de28148',
        },
      },
    )
  when 'aarch64', 'arm64'
    package_info = value_for_platform(
      'ubuntu' => {
        '20.04' => {
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.5.0/ubuntu/20.04/cinc_18.5.0-1_arm64.deb',
          'checksum' => '6037cd2c35898ed388372adcbe267e7833546488750596e1a802b87ca6f9b614',
        },
        '22.04' => {
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.5.0/ubuntu/22.04/cinc_18.5.0-1_arm64.deb',
          'checksum' => 'a4d858a02e135f61b8183a1db037b27f1cb45cdaf43e1492e8a7bda660fc5189',
        },
        '24.04' => {
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.5.0/ubuntu/22.04/cinc_18.5.0-1_arm64.deb',
          'checksum' => 'a4d858a02e135f61b8183a1db037b27f1cb45cdaf43e1492e8a7bda660fc5189',
        },
      },
    )
  end
when 'centos'
  case node['kernel']['machine']
  when 'x86_64', 'amd64'
    package_info = value_for_platform(
      'centos' => {
        '9' => {
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.4.12/el/9/cinc-18.4.12-1.el9.x86_64.rpm',
          'checksum' => '9f6e66e5fb6ce9834ed8bf147de39fb2290091311257777167c4dd107a28e37d',
        },
      },
    )
  when 'aarch64', 'arm64'
    package_info = value_for_platform(
      'centos' => {
        '9' => {
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.4.12/el/9/cinc-18.4.12-1.el9.aarch64.rpm',
          'checksum' => 'c08d3e36ad706b1d5e80fb55f42548784760b3ccaf758860d005b4edbf8d6761',
        },
      },
    )
  end
end

local_path = ::File.join(Chef::Config[:file_cache_path], ::File.basename(package_info['url']))

remote_file local_path do
  source package_info['url']
  checksum package_info['checksum']
end

ruby_block 'reexec chef' do
  block do
    exec('/opt/cinc/bin/cinc-client --no-fork --force-logger --no-color')
  end
  action :nothing
end

case node['platform']
when 'ubuntu'
  dpkg_package 'cinc' do
    source local_path
    only_if { node.default['boxcutter_chef']['cinc_client']['manage_packages'] }
    only_if { node.debian? || node.ubuntu? }
    action :upgrade
    notifies :run, 'ruby_block[reexec chef]', :immediately
  end
when 'centos'
  dnf_package 'cinc' do
    source local_path
    only_if { node.default['boxcutter_chef']['cinc_client']['manage_packages'] }
    only_if { node.centos? || node.fedora? }
    action :upgrade
    notifies :run, 'ruby_block[reexec chef]', :immediately
  end
end

link '/opt/chef' do
  to '/opt/cinc'
end

config_dir = '/etc/cinc'
config_symlink = '/etc/chef'

[
  '/var/chef',
  config_dir,
].each do |dir|
  directory dir do
    owner 'root'
    group 'root'
    mode '0755'
  end
end

link config_symlink do
  to config_dir
end

%w{
  chef-apply
  chef-client
  chef-shell
  chef-solo
}.each do |f|
  link "/usr/bin/#{f}" do
    to '/opt/cinc/bin/cinc-wrapper'
  end
end

ruby_block 'reload_client_config' do
  block do
    Chef::Config.from_file("#{config_dir}/client.rb")
  end
  action :nothing
end

template "#{config_dir}/client-prod.rb" do
  source 'client-prod.rb.erb'
  cookbook 'boxcutter_chef'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :create, 'ruby_block[reload_client_config]', :immediately
end

link "#{config_dir}/client.rb" do
  # don't overwrite this if it's a link ot somewhere else, because
  # taste-tester
  not_if { File.symlink?("#{config_dir}/client.rb") }
  to "#{config_dir}/client-prod.rb"
end

link "#{config_dir}/client.pem" do
  # don't overwrite this if it's a link ot somewhere else, because
  # taste-tester
  not_if { File.symlink?("#{config_dir}/client.pem") }
  to "#{config_dir}/client-prod.pem"
end

template "#{config_dir}/run-list.json" do
  source 'run-list.json.erb'
  cookbook 'boxcutter_chef'
  owner 'root'
  group 'root'
  mode '0644'
end
