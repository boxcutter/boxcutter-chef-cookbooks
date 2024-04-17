#
# Cookbook:: boxcutter_site_settings
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

node.default['fb_users']['user_defaults']['gid'] = 'boxcutter'

if node.ubuntu?
  # us.archive.ubuntu.com and the core Ubuntu repositories do not have ARM
  # binaries. ARM binaries are only on ports.ubuntu.com
  node.default['fb_apt']['mirror'] = if node['kernel']['machine'] == 'aarch64'
                                       'http://ports.ubuntu.com/ubuntu-ports'
                                     else
                                       'http://archive.ubuntu.com/ubuntu'
                                     end

  node.default['fb_apt']['security_mirror'] = if node['kernel']['machine'] == 'aarch64'
                                                'http://ports.ubuntu.com/ubuntu-ports'
                                              else
                                                'http://security.ubuntu.com/ubuntu'
                                              end
end

include_recipe '::dnf'
