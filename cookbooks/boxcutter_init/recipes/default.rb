#
# Cookbook:: boxcutter_init
# Recipe:: default
#
# Copyright:: 2023, Boxcutter
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

# SANITY-INDUCING HACK
# If we have never run before, run in debug mode. This ensures that for
# first run/bootstrapping issues we have lots of visibility.
if node.firstboot_any_phase?
  Chef::Log.info('Enabling debug log for first run')
  Chef::Log.level = :debug
end

# this should be first.
include_recipe 'boxcutter_init::site_settings'

if node.centos?
  # HERE: yum
  include_recipe 'fb_rpm'
end
if node.debian? || node.ubuntu?
  include_recipe 'fb_apt'
end