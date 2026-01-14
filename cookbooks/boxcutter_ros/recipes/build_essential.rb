#
# Cookbook:: boxcutter_ros
# Recipe:: build_essential
#
# Copyright:: 2025-present, Taylor.dev, LLC
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

# Includes only the packages that are required for building standalone ROS 2
# packages. ROS developers should use ros::dev_tools instead for the full set
# of recommended tools.

unless node.ubuntu?
  fail 'boxcutter_ros is only supported onUbuntu.'
end

%w{
  build-essential
  cmake
  git
  python3-pip
}.each do |pkg|
  package pkg do
    action :upgrade
  end
end
