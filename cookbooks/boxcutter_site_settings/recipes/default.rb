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

puts "MISCHA: node['boxcutter_config']['tier] = #{node['boxcutter_config']['tier']}"
node.default['fb_users']['user_defaults']['gid'] = 'boxcutter'
include_recipe 'boxcutter_users'

include_recipe '::ssh'

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

  # Timesync is masked by default in Ubuntu now
  if node.systemd?
    node.default['fb_systemd']['timesyncd']['enable'] = false
  end
end

include_recipe '::dnf'

node.default['fb_ssh']['sshd_config']['X11Forwarding'] = true

if node.linux?
  include_recipe '::users'
end
