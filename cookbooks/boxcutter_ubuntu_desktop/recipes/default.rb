#
# Cookbook:: boxcutter_ubuntu_desktop
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

node.default['fb_systemd']['default_target'] = 'graphical.target'

node.default['fb_users']['users']['boxcutter'] = {
  'gid' => 'users',
  'home' => '/home/boxcutter',
  'shell' => '/bin/bash',
  'action' => :add,
}

directory '/home/boxcutter/.config' do
  owner 'boxcutter'
  group 'users'
end

# Disable Gnome initial setup
file '/home/boxcutter/.config/gnome-initial-setup-done' do
  content 'yes'
  owner 'boxcutter'
  group 'users'
  mode '0600'
end

node.default['boxcutter_ubuntu_desktop']['gdm_custom']['daemon']['AutomaticLoginEnable'] = 'true'
node.default['boxcutter_ubuntu_desktop']['gdm_custom']['daemon']['AutomaticLogin'] = 'boxcutter'

package 'gdm3' do
  action :upgrade
end

# Does not notify gdm3 to restart on changes as it will logout the current user
template '/etc/gdm3/custom.conf' do
  owner 'root'
  group 'root'
  mode '0644'
end
