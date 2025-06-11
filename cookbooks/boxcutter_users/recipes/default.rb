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
  'emerson' => '2004',
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
  'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINy9cJcJl8oN6bRtcBc4RZq8f/T6P1AFR3YS1YRYi5YY sheila'
node.default['fb_ssh']['authorized_keys']['taylor']['joan'] =
  'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHGTw44QBehDXY6ebitrYydyAAhDFLBSkQ59RovcVsvX joan'
node.default['fb_ssh']['authorized_keys']['sheila']['mahowald'] =
  'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMC7b+X2a0mRV8A7W5zolbrkALqFizKtuhmM+xZWKohl sheila@mahowald'
node.default['fb_ssh']['authorized_keys']['emerson']['macbook_air'] =
  'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDNUBlByk5k7w+IT45y1X1OEAQmKP8LdRPXkt' \
  'wtKeKD970QyiL1G6jVUB+RVSC/1uxZSik8t47aBQrQSIm/gErCwbVcty3TyIVJENImVHRYIDny' \
  'jRZY3+HoZGhoMWtZ8IOxrH+lXLd9taUA0Pzdcv9dn0oxNfi/RVqAalOAFXQfB9cvNyxhcVZhAm' \
  'W4fc5DHjRAOYbW0J4qrKq398wS57+4zHpZo7s0jNDwqFhOlo+hWMUKBlcjReXc4C+ohh6dQjnK' \
  'EKfhpGajp2nWjkgPlePPHA5IXFe1nl7+YVUIzjpj7+aTgtjkOsdmpYmtqXc1IbCCDSvPuZGq8B' \
  'z32PssnRvFAVSSmY+cwZ1KWoVUBCeWW5eYvEcnhRx6pjAS6mm8GmMBWky+GmWof1/294h8s4Gn' \
  'Oq5108lFjRizMEJDq2M6W4k98L44pu1xTIspWQb4rWzcnWrFz2YP6qHU9UiNxBhu/wcd8gChYk' \
  'NTSX4hCU36qOsvTYruokccbE/H0TnQu7c= emerson@macbook-air.lan'
node.default['fb_ssh']['authorized_keys']['emerson']['pop_os1'] =
  'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDJdGJm8wzYku7fdvPBVBDQuPakISo2LAV07X' \
  'wNUyp5PisnPIfmOTUFKWKh6aaElF+z7T2V8on7HZ3XH94q9M/st+5fwFXv3vIMhlJYKn33eqXH' \
  'GEwFmhrjtsxWER5V1RcykDMDKIn7Q8BxYeAXfBBUAzIxrr8kGXu3VivhGN+A75mgdF37qb7suQ' \
  'xkmh+Lmbpal4vuR+Rg9xKOaMG8LDbx9buOA2Rcp6+K0r9glhVBx1TjrFkbXGzu0WYciFNlLx14' \
  'lqCyBHS/ybcSeVOx3L7j0MG7qIyCXwIFLCAjC7Rmxqu9L05yfOeuzCyNc9PO+GtPB/H3NMv5Fr' \
  'Sq2mAn+aO9DmpI3BSBGxpyi/x9404V9IEEbwyzbKrBdC9RVos9eZr0Gz8onpXs8twwiYrl9K77' \
  '6yw7JwRlBF2aXYAbuKj7jQTUo0fNPX+py4P4mbuXubCK087G+09fVd2iG218xS8DLMFghn5Qed' \
  'LVgOluUhORwVTsZCc97K+3e513CUrNdws= emerson@pop-os'
node.default['fb_ssh']['authorized_keys']['emerson']['pop_os2'] =
  'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC3EdZxlEhRxAndKQhq7REhzI4OB2/MDQFxwB' \
  'P5GneSoAAxkefgwBgmxjbGbPsAEM75lD5PpJNPhEzJ7nis9358KAu69frMbwFqpUuBQxJ2wqk1' \
  'gsdHKf10xaz+TkmtY6+Gh6ZVm48nnuxCCG/2C+qwVViUpib082LM8Kcfu3HNJQcQ18jgV2vVfg' \
  'G6zaEcYpovpgyZUeMVuFei4vuE4MjRx3RBAP8mQF/SAXq+OVmz8g+vY6/yCPhOF+ZpHr+EdKaL' \
  'BLAyYgdbcndyR2P1UQE3Nst2Iz+zabnPqOKOExoC5wtkuSgTOfKyjeJZ3uQAOTlVsFoITuAdFc' \
  'Ee37bhDgedYOU9+Vnp/1hIls8Fa9eczzDes+UzoC3nX1LVHaoqz6ISjAGjUSqMtCf8i7eWNlRw' \
  'QL2jsCNtD0L7BqcvhIw89LsFP7lKT7FuvVJXEuFo3b4cbD2lKGgBtIBBaiQzhAJWWoPCvjME51' \
  'uGOTH3XmTnGe6jjLD5WfVylFZDOkwSxPc= emerson@pop-os'

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
    'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINy9cJcJl8oN6bRtcBc4RZq8f/T6P1AFR3YS1YRYi5YY sheila'
  node.default['fb_ssh']['authorized_keys']['root']['joan'] =
    'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHGTw44QBehDXY6ebitrYydyAAhDFLBSkQ59RovcVsvX joan'
end
