#
# Cookbook:: boxcutter_users
# Recipe:: default
#
# Copyright:: 2023-present, Taylor.dev, LLC
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
  node.default['fb_users']['users'][user] = {
    'gid' => 'users',
    'shell' => '/bin/bash',
    'action' => :add,
  }

  user user do
    uid uid
    group 'users'
    home "/home/#{user}"
    manage_home true
    shell '/bin/bash'
  end

  node.default['fb_sudo']['users'][user]['caretaker'] = 'ALL=(ALL:ALL) NOPASSWD: ALL'
end

FB::Users.initialize_group(node, 'boxcutter')

# group 'sudo' do
#   members caretakers.keys
#   system true
#   gid 2001
# end

node.default['fb_sudo']['users']['%sudo']['dont prompt for password'] = 'ALL=(ALL:ALL) NOPASSWD:ALL'

node.default['fb_ssh']['enable_central_authorized_keys'] = true

node.default['fb_ssh']['authorized_keys']['taylor']['mahowald'] =
  'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINRK4hkcpUiaSkiLEytgwMYcKylBioXPLx1TnwJFrLPl mahowald'
node.default['fb_ssh']['authorized_keys']['taylor']['sheila'] =
  'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEWerEkujoB7ipGnWJwnPGFu3DuUQJtc1zB6YqjGRziE sheila'

# If we're running in test kitchen on digitalocean, make sure ssh keys for
# root aren't nuked so that "kitchen login" works after the first
# "kitchen converge"
if kitchen? && digital_ocean?
  node.default['fb_ssh']['sshd_config']['PermitRootLogin'] = 'without-password'
  node.default['fb_ssh']['sshd_config']['X11Forwarding'] = true
  node.default['fb_sudo']['users']['root']['sudo'] = 'ALL=(ALL:ALL) NOPASSWD:ALL'
  node.default['fb_ssh']['authorized_keys']['root']['mahowald'] =
    'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINRK4hkcpUiaSkiLEytgwMYcKylBioXPLx1TnwJFrLPl mahowald'
  node.default['fb_ssh']['authorized_keys']['root']['sheila'] =
    'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEWerEkujoB7ipGnWJwnPGFu3DuUQJtc1zB6YqjGRziE sheila'
end
