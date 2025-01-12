#
# Cookbook:: boxcutter_ros
# Recipe:: user
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

ros_user = 'ros'
ros_group = 'ros'
ros_home = '/home/ros'

FB::Users.initialize_group(node, ros_group)

node.default['fb_users']['users'][ros_user] = {
  'gid' => ros_group,
  'home' => ros_home,
  'shell' => '/bin/bash',
  'action' => :add,
}

directory "#{ros_home}/.bashrc.d" do
  owner ros_user
  group ros_group
  mode '0700'
end

template "#{ros_home}/.bashrc.d/120.ros.bashrc" do
  source 'ros.bashrc.erb'
  owner ros_user
  group ros_group
  mode '0700'
end

template ::File.join(ros_home, '.bashrc') do
  source 'user.bashrc.erb'
  owner ros_user
  group ros_group
  mode '0644'
end
