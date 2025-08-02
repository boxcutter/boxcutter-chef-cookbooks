#
# Cookbook:: boxcutter_acme
# Recipe:: lego
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

case node['kernel']['machine']
when 'x86_64', 'amd64'
  version = '4.17.4'
  url = 'https://github.com/go-acme/lego/releases/download/v4.17.4/lego_v4.17.4_linux_amd64.tar.gz'
  checksum = 'f362d59ff5b6f92c599e3151dcf7b6ed853de05533be179b306ca40a7b67fb47'
when 'aarch64', 'arm64'
  version = '4.17.4'
  url = 'https://github.com/go-acme/lego/releases/download/v4.17.4/lego_v4.17.4_linux_arm64.tar.gz'
  checksum = 'b79c3a2bad15c2359524a3372361377e09c15d0efe6a51223cdccf036d3f6e98'
end

tmp_path = ::File.join(Chef::Config[:file_cache_path], ::File.basename(url))

remote_file tmp_path do
  source url
  checksum checksum
end

path = ::File.join('/opt/lego', version, 'bin')

[
  '/opt/lego',
  '/opt/lego/latest',
  ::File.join('/opt/lego', version),
  ::File.join('/opt/lego', version, 'bin'),
  path,
].each do |dir|
  directory dir do
    owner node.root_user
    group node['root_group']
    mode '0755'
  end
end

execute 'extract lego' do
  command <<-BASH
    tar --extract --directory #{path} --file #{tmp_path}
  BASH
  creates "#{path}/bin/lego"
end

link '/opt/lego/latest/bin' do
  to path.to_s
end

node.default['boxcutter_acme']['lego']['config'].each do |name, config|
  template config['renew_script_path'] do
    source 'lego_renew.sh.erb'
    owner 'root'
    group 'root'
    mode '0700'
    variables(
      :certificate_name => config['certificate_name'],
      :data_path => config['data_path'],
      :server => config.key?('server') || 'https://acme-v02.api.letsencrypt.org/directory',
      :email => config['email'],
      :domains => config['domains'].join(' '),
      :cloudflare_dns_api_token => config['cloudflare_dns_api_token'],
      :extra_parameters => config.key?('extra_parameters') ? config['extra_parameters'].join(' ') : '--http',
      :extra_environment => config['extra_environment'],
      :renew_days => config['renew_days'] || 30,
    )
  end

  node.default['fb_timers']['jobs'][name] = {
    'calendar' => FB::Systemd::Calendar.every.weekday,
    'command' => config['renew_script_path'],
    'accuracy' => '1h',
    'splay' => '0.5h',
  }
end
