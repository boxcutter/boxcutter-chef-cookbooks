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
node.default['fb_ssh']['authorized_keys']['sheila']['mahowald'] =
  'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMC7b+X2a0mRV8A7W5zolbrkALqFizKtuhmM+xZWKohl sheila@mahowald'
node.default['fb_ssh']['authorized_keys']['david']['primary'] =
  'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGrsc/f7awkWNJn/mUM5Z4It61b+AqpHvFpnV6bxn8vT dtarazi@olin.edu'
node.default['fb_ssh']['authorized_keys']['david']['primary'] =
  'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKyLT95GOjIh1FsXyyeUDzr7JubWRxq3KvP7cmUfsfYm david@polymathrobotics.com'
