#
# Cookbook:: boxcutter_chef
# Recipe:: cinc_client
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

# kitchen-dokken volume mounts cinc in as /opt/cinc from a container image.
# Don't try to manage packages in this scenario.
if ::Pathname.new('/opt/cinc').mountpoint?
  node.default['boxcutter_chef']['cinc_client']['manage_packages'] = false
end

remote_file 'cinc_installer' do
  path lazy {
         ::File.join(Chef::Config[:file_cache_path], ::File.basename(node['boxcutter_chef']['cinc_client']['source']))
       }
  source lazy { node['boxcutter_chef']['cinc_client']['source'] }
  checksum lazy { node['boxcutter_chef']['cinc_client']['checksum'] }
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
    source lazy {
             ::File.join(Chef::Config[:file_cache_path],
                         ::File.basename(node['boxcutter_chef']['cinc_client']['source']))
           }
    action :upgrade
    only_if { node.default['boxcutter_chef']['cinc_client']['manage_packages'] }
    only_if { node.debian? || node.ubuntu? }
    notifies :run, 'ruby_block[reexec chef]', :immediately
  end
when 'centos'
  dnf_package 'cinc' do
    source lazy {
             ::File.join(Chef::Config[:file_cache_path],
                         ::File.basename(node['boxcutter_chef']['cinc_client']['source']))
           }
    action :upgrade
    only_if { node.default['boxcutter_chef']['cinc_client']['manage_packages'] }
    only_if { node.centos? || node.fedora? }
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

cookbook_file "#{config_dir}/handlers/metrics_handler.rb" do
  source 'config/metrics_handler.rb'
  owner 'root'
  group 'root'
  mode '0644'
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

cookbook_file '/usr/local/sbin/chef_metrics_collector.sh' do
  source 'metrics/chef_metrics_collector.sh'
  owner 'root'
  group 'root'
  mode '0755'
end

node.default['fb_timers']['jobs']['collect_chef_metrics'] = {
  'calendar' => FB::Systemd::Calendar.every(2).minutes,
  'command' => '/usr/local/sbin/chef_metrics_collector.sh',
  'only_if' => proc { File.exist?('/var/lib/node_exporter/textfile') },
}