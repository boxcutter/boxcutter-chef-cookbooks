#
# Cookbook:: boxcutter_workstation
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

workstation_hosts = %w{
  crake-stunt-ubuntu2204
  crake-stunt-ubuntu2404
}.include?(node['hostname'])

if workstation_hosts
  include_recipe 'boxcutter_ubuntu_desktop'
end
