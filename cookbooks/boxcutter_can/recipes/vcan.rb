#
# Cookbook:: boxcutter_can
# Recipe:: vcan
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

node.default['fb_modprobe']['modules_to_load_on_boot'] << 'vcan'

fb_modprobe_module 'vcan' do
  action :load
end

node.default['fb_networkd']['primary_interface'] = nil
node.default['fb_networkd']['networks'].delete('eth0')
node.default['fb_networkd']['networks']['vcan0'] = {
  'config' => {
    'Match' => {
      'Name' => 'vcan0',
    },
  },
}
node.default['fb_networkd']['devices']['vcan0']['config'] = {
  'NetDev' => {
    'Name' => 'vcan0',
    'Kind' => 'vcan',
    'MTUBytes' => '16',
    'Description' => 'Virtual CAN0 network interface',
  },
}

# Ensure that systemd-networkd is enabled and started
service 'systemd-networkd' do
  action [:enable, :start]
end
