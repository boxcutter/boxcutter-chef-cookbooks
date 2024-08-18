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
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.4.12/ubuntu/20.04/cinc_18.4.12-1_amd64.deb',
          'checksum' => 'ac02fab9c6351893e250b3ba91d6604dfffedefe80609d44ab2189caea281ca2',
        },
        '22.04' => {
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.4.12/ubuntu/22.04/cinc_18.4.12-1_amd64.deb',
          'checksum' => 'f79d89bad254ce9a2881eed77cd5f0d9a172f4e2ed29f161cb620206b0d103a6',
        },
        '24.04' => {
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.4.12/ubuntu/22.04/cinc_18.4.12-1_amd64.deb',
          'checksum' => 'f79d89bad254ce9a2881eed77cd5f0d9a172f4e2ed29f161cb620206b0d103a6',
        },
      },
    )
  when 'aarch64', 'arm64'
    package_info = value_for_platform(
      'ubuntu' => {
        '20.04' => {
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.4.12/ubuntu/20.04/cinc_18.4.12-1_arm64.deb',
          'checksum' => 'e83412c10f1daa47c92d2230486cb29e43a42f07c9e89a3cd4ccc71d31a0026c',
        },
        '22.04' => {
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.4.12/ubuntu/22.04/cinc_18.4.12-1_arm64.deb',
          'checksum' => 'c98805280ac44428af455f245ea1892e707bb45a68b12ca50ddf78978ede7856',
        },
        '24.04' => {
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.4.12/ubuntu/22.04/cinc_18.4.12-1_arm64.deb',
          'checksum' => 'c98805280ac44428af455f245ea1892e707bb45a68b12ca50ddf78978ede7856',
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
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.5.0/el/9/cinc-18.5.0-1.el9.x86_64.rpm',
          'checksum' => '644a0bf1de601d886a6886bd099523704c948c1f49fccc4b97b3f074388db081',
        },
      },
    )
  when 'aarch64', 'arm64'
    package_info = value_for_platform(
      'centos' => {
        '9' => {
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.5.0/el/9/cinc-18.5.0-1.el9.aarch64.rpm',
          'checksum' => '9cb55dcc3763a8669c1f701af94c1fda0e6ccfc76c41e4ee76f8de6534f9bca9',
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
