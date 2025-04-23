#
# Cookbook:: boxcutter_ros
# Recipe:: dev_tools
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

unless node.ubuntu?
  fail 'boxcutter_ros is only supported onUbuntu.'
end

include_recipe 'boxcutter_ros::common'
include_recipe 'boxcutter_ros::build_essential'

%w{
  python3-colcon-common-extensions
  python3-vcstool
  python3-rosdep
}.each do |pkg|
  package pkg do
    action :upgrade
  end
end
