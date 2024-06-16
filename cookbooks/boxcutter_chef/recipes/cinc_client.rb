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
