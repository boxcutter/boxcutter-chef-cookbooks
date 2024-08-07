#
# Cookbook:: boxcutter_users
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

caretakers = {
  'sheila' => '2002',
  'taylor' => '2003',
}

caretakers.each do |user, uid|
  user user do
    uid uid
    group 'users'
    home "/home/#{user}"
    manage_home true
    shell '/bin/bash'
  end
end

group 'sudo' do
  members caretakers.keys
  system true
  gid 2001
end

node.default['fb_sudo']['users']['%sudo']['dont prompt for password'] = 'ALL=NOPASSWD: ALL'

node.default['fb_ssh']['enable_central_authorized_keys'] = true

node.default['fb_ssh']['authorized_keys']['taylor']['mahowald'] =
  'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDBZjVID1mAqZyhD3p0VbJtidKAxMHUwLmEMaCAJX0UN mahowald'
node.default['fb_ssh']['authorized_keys']['taylor']['sheila'] =
  'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINy9cJcJl8oN6bRtcBc4RZq8f/T6P1AFR3YS1YRYi5YY sheila'
node.default['fb_ssh']['authorized_keys']['taylor']['crake_chef_workstation'] =
  'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFgc04AMr0cqL3Il8l+jSuRtgHAjntGzDltnOCB2Uihz crakeChefWorkstation'
node.default['fb_ssh']['authorized_keys']['sheila']['mahowald'] =
  'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMC7b+X2a0mRV8A7W5zolbrkALqFizKtuhmM+xZWKohl sheila@mahowald'
node.default['fb_ssh']['authorized_keys']['david']['primary'] =
  'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGrsc/f7awkWNJn/mUM5Z4It61b+AqpHvFpnV6bxn8vT dtarazi@olin.edu'
node.default['fb_ssh']['authorized_keys']['david']['primary'] =
  'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKyLT95GOjIh1FsXyyeUDzr7JubWRxq3KvP7cmUfsfYm david@polymathrobotics.com'
