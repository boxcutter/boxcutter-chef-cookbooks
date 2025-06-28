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
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.6.2/ubuntu/20.04/cinc_18.6.2-1_amd64.deb',
          'checksum' => '0547888512fdb96a823933bc339ebb28f85796e2ceffae4922cf5e7ee26f094b',
        },
        '22.04' => {
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.6.2/ubuntu/22.04/cinc_18.6.2-1_amd64.deb',
          'checksum' => '043c2cb693d1b6038a3341b471efdb5726d7b08c55f4835a1fb59a6a7f1fba21',
        },
        '24.04' => {
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.6.2/ubuntu/24.04/cinc_18.6.2-1_amd64.deb',
          'checksum' => '48d4e2f5a5befd6a18a90c7dc05aa038a5032825b048e5614dec0e0e83eca42c',
        },
      },
    )
  when 'aarch64', 'arm64'
    package_info = value_for_platform(
      'ubuntu' => {
        '20.04' => {
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.6.2/ubuntu/20.04/cinc_18.6.2-1_arm64.deb',
          'checksum' => 'f3181b8fcf7aee139b317c152e7c2b2a564b8024faa58e568e897ad01bdff782',
        },
        '22.04' => {
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.6.2/ubuntu/22.04/cinc_18.6.2-1_arm64.deb',
          'checksum' => 'a7404177b1bca4eae8b6e79992e6c68606d0da545604635a074cc52ab42dce24',
        },
        '24.04' => {
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.6.2/ubuntu/24.04/cinc_18.6.2-1_arm64.deb',
          'checksum' => 'f36a1b948f0a3559a7eb4ee60c5512586a961c315f135f281faa7f15623ba560',
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
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.6.2/el/9/cinc-18.6.2-1.el9.x86_64.rpm',
          'checksum' => '26ebe3eeb91121def370c44414394fc9a396359c285df6e6a561cfd251cd20f6',
        },
        '10' => {
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.6.2/el/10/cinc-18.6.2-1.el10.x86_64.rpm',
          'checksum' => '3cb1ca62a4fd603f6ee9f8728f04416b3a3226099c6332790357d909936733d5',
        },
      },
    )
  when 'aarch64', 'arm64'
    package_info = value_for_platform(
      'centos' => {
        '9' => {
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.6.2/el/9/cinc-18.6.2-1.el9.aarch64.rpm',
          'checksum' => '3c9091f1f81e7e57410c9d0043fede5c9bc5748d1c204e74b553f726435cf0d2',
        },
        '10' => {
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.6.2/el/10/cinc-18.6.2-1.el10.aarch64.rpm',
          'checksum' => 'fa45d047567ebe4ff40d728f586264fc3e0d42c24545f635dcd001bae850b447',
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
    client_rb_path = "#{config_dir}/client.rb"
    if ::File.exist?(client_rb_path)
      Chef::Config.from_file("#{config_dir}/client.rb")
    end
  end
  action :nothing
end

directory "#{config_dir}/handlers" do
  owner 'root'
  group 'root'
  mode '0755'
end

cookbook_file "#{config_dir}/handlers/attribute_changed_handler.rb" do
  source 'config/attribute_changed_handler.rb'
  owner 'root'
  group 'root'
  mode '0644'
end

cookbook_file "#{config_dir}/handlers/attribute-changed-handler.rb" do
  action :delete
end

# cookbook_file "#{config_dir}/handlers/resource-updated-handler.rb" do
#   source 'config/resource-updated-handler.rb'
#   owner 'root'
#   group 'root'
#   mode '0644'
# end

cookbook_file "#{config_dir}/handlers/resource-updated-handler.rb" do
  action :delete
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
