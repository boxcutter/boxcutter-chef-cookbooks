#
# Cookbook:: boxcutter_golang
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

case node['kernel']['machine']
when 'x86_64', 'amd64'
  node.default['boxcutter_golang']['binary'] = {
    'version' => '1.23.1',
    'source' => 'https://go.dev/dl/go1.23.1.linux-amd64.tar.gz',
    'checksum' => '49bbb517cfa9eee677e1e7897f7cf9cfdbcf49e05f61984a2789136de359f9bd',
    'creates' => 'bin/go',
  }
when 'aarch64', 'arm64'
  node.default['boxcutter_golang']['binary'] = {
    'version' => '1.23.1',
    'source' => 'https://go.dev/dl/go1.23.1.linux-arm64.tar.gz',
    'checksum' => 'faec7f7f8ae53fda0f3d408f52182d942cc89ef5b7d3d9f23ff117437d4b2d2f',
    'creates' => 'bin/go',
  }
end

source = node['boxcutter_golang']['binary']['source']
checksum = node['boxcutter_golang']['binary']['checksum']
version = node['boxcutter_golang']['binary']['version']
creates = node['boxcutter_golang']['binary']['creates']
filename = ::File.basename(source)
tmp_path = ::File.join(Chef::Config[:file_cache_path], filename)

remote_file tmp_path do
  source source
  checksum checksum
end

[
  '/opt/go',
  "/opt/go/#{version}",
].each do |dir|
  directory dir do
    owner node['root_user']
    group node['root_group']
    mode '0755'
  end
end

execute 'extract golang' do
  command <<-BASH
    tar --extract --strip-components=1 --directory "/opt/go/#{version}" --file #{tmp_path}
  BASH
  creates "/opt/go/#{version}/#{creates}"
end

link '/opt/go/latest' do
  to "/opt/go/#{version}"
end

link '/usr/local/go' do
  to "/opt/go/#{version}"
end
