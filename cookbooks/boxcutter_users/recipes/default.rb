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
  'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEV40AiHWQUCXY7Yh3s5Vj/ZtRc1BWex6D2+eoEnRXM7 mahowald'
node.default['fb_ssh']['authorized_keys']['taylor']['mahowald_home'] =
  'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBCgywUNFPmqOmYm1kThp++UV+tFR+VX8zEbRoemD/CQ mahowald-home'
node.default['fb_ssh']['authorized_keys']['taylor']['mahowald_boxcutter'] =
  'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJjcnD2uG+DPInpQcYZpmZtMevxMzVT5yKIi2+cT4rsq mahowald-boxcutter'
node.default['fb_ssh']['authorized_keys']['taylor']['sheila'] =
  'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINy9cJcJl8oN6bRtcBc4RZq8f/T6P1AFR3YS1YRYi5YY sheila'
node.default['fb_ssh']['authorized_keys']['taylor']['sheila_home'] =
  'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMQs5gtlb+OtvTvdFu8ujoI+G4ElkJudZpxDtnwCZybA sheila-home'
node.default['fb_ssh']['authorized_keys']['taylor']['sheila_boxcutter'] =
  'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIER06I4w+0j+CCvu36b9aCGA1HDDx1EOEKJ3inZSGDrw shelia-boxcutter'
node.default['fb_ssh']['authorized_keys']['taylor']['joan'] =
  'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHGTw44QBehDXY6ebitrYydyAAhDFLBSkQ59RovcVsvX joan'
node.default['fb_ssh']['authorized_keys']['taylor']['joan_home'] =
  'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICV7K2rMcsUmT1v1VChPu552ux/GXe/CWWmAkj7ryo9N joan-home'
node.default['fb_ssh']['authorized_keys']['taylor']['joan_boxcutter'] =
  'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPxZsm6W83hWKZ+T0RLGtx6E8scnjq2o3GMjkXx+P1Bi joan-boxcutter'
node.default['fb_ssh']['authorized_keys']['taylor']['emily'] =
  'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMWwrOVfOWfax6HR4Y+Mg01jT9No2zXHqkATnqwHuFKU emily'
node.default['fb_ssh']['authorized_keys']['sheila']['mahowald'] =
  'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMC7b+X2a0mRV8A7W5zolbrkALqFizKtuhmM+xZWKohl sheila@mahowald'

# If we're running in test kitchen on digitalocean, make sure ssh keys for
# root aren't nuked so that "kitchen login" works after the first
# "kitchen converge"
if kitchen? && digital_ocean?
  node.default['fb_ssh']['sshd_config']['PermitRootLogin'] = 'without-password'
  node.default['fb_ssh']['sshd_config']['X11Forwarding'] = true
  node.default['fb_sudo']['users']['root']['sudo'] = 'ALL=(ALL:ALL) NOPASSWD:ALL'
  node.default['fb_ssh']['authorized_keys']['root']['mahowald'] =
    'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEV40AiHWQUCXY7Yh3s5Vj/ZtRc1BWex6D2+eoEnRXM7 mahowald'
  node.default['fb_ssh']['authorized_keys']['root']['mahowald_home'] =
    'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBCgywUNFPmqOmYm1kThp++UV+tFR+VX8zEbRoemD/CQ mahowald-home'
  node.default['fb_ssh']['authorized_keys']['root']['mahowald_boxcutter'] =
    'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJjcnD2uG+DPInpQcYZpmZtMevxMzVT5yKIi2+cT4rsq mahowald-boxcutter'
  node.default['fb_ssh']['authorized_keys']['root']['sheila'] =
    'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINy9cJcJl8oN6bRtcBc4RZq8f/T6P1AFR3YS1YRYi5YY sheila'
  node.default['fb_ssh']['authorized_keys']['root']['sheila_home'] =
    'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMQs5gtlb+OtvTvdFu8ujoI+G4ElkJudZpxDtnwCZybA sheila-home'
  node.default['fb_ssh']['authorized_keys']['root']['sheila_boxcutter'] =
    'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIER06I4w+0j+CCvu36b9aCGA1HDDx1EOEKJ3inZSGDrw shelia-boxcutter'
  node.default['fb_ssh']['authorized_keys']['root']['joan'] =
    'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHGTw44QBehDXY6ebitrYydyAAhDFLBSkQ59RovcVsvX joan'
  node.default['fb_ssh']['authorized_keys']['root']['joan_home'] =
    'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICV7K2rMcsUmT1v1VChPu552ux/GXe/CWWmAkj7ryo9N joan-home'
  node.default['fb_ssh']['authorized_keys']['root']['joan_boxcutter'] =
    'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPxZsm6W83hWKZ+T0RLGtx6E8scnjq2o3GMjkXx+P1Bi joan-boxcutter'
end
