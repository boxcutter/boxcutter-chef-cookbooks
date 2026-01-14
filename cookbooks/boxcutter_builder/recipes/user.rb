#
# Cookbook:: boxcutter_builder
# Recipe:: user
#
# Copyright:: 2024-present, Taylor.dev, LLC
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

build_user = 'craft'
build_group = 'craft'

# caretakers.each do |user, uid|
#   user user do
#     uid uid
#     group 'users'
#     home "/home/#{user}"
#     manage_home true
#     shell '/bin/bash'
#   end
# end
#
# group 'sudo' do
#   members caretakers.keys
#   system true
#   gid 2001
# end

node.default['fb_users']['users'][build_user] = {
  'action' => :add,
  'home' => "/home/#{build_user}",
  'shell' => '/bin/bash',
}

node.default['fb_users']['groups'][build_group] = {
  'members' => [build_user],
  'action' => :add,
}

include_recipe 'boxcutter_onepassword::cli'

craft_ssh_private_key = Boxcutter::OnePassword.op_read('op://Automation-Org/craft SSH Key/private key')
craft_ssh_public_key = Boxcutter::OnePassword.op_read('op://Automation-Org/craft SSH Key/public key')

directory "/home/#{build_user}/.ssh" do
  owner build_user
  group build_group
  mode '0700'
end

file "/home/#{build_user}/.ssh/id_rsa" do
  content craft_ssh_private_key
  owner build_user
  group build_group
  mode '0600'
end

file "/home/#{build_user}/.ssh/id_rsa.pub" do
  content craft_ssh_public_key
  owner build_user
  group build_group
  mode '0655'
end

# ssh-keyscan -H 10.63.34.15
# ssh_known_hosts_entry '10.63.34.15' do
#   file_location "/home/#{build_user}/.ssh/known_hosts"
#   owner build_user
#   group build_group
# end

node.default['fb_ssh']['authorized_keys']['craft']['ubuntu-2004'] = craft_ssh_public_key

# cookbook_file "/home/#{build_user}/.ssh/config" do
#  owner build_user
#  group build_config
# mode '0600'
#  source 'github_config'
# end
