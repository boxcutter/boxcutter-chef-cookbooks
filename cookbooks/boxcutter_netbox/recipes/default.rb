#
# Cookbook:: boxcutter_netbox
# Recipe:: default
#
# Copyright:: 2025, Boxcutter
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

include_recipe 'boxcutter_postgresql::server'
include_recipe 'boxcutter_redis'
include_recipe 'boxcutter_python::system'

%w{
  build-essential
  python3-dev
  libpq-dev
}.each do |pkg|
  package pkg do
    action :upgrade
  end
end

FB::Users.initialize_group(node, 'netbox')
node.default['fb_users']['users']['netbox'] = {
  'gid' => 'netbox',
  'home' => '/home/netbox',
  'shell' => '/bin/bash',
  'action' => :add,
}

boxcutter_netbox_tarball 'netbox' do
  version '4.2.7'
  source 'https://github.com/netbox-community/netbox/archive/refs/tags/v4.2.7.tar.gz'
  checksum '68ac882c5bb9de163fccf8b6f2ce91116dda964126a05baa4c5831e82cbd72bd'
  creates  'upgrade.sh'
end
