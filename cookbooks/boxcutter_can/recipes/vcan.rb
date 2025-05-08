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

package 'can-utils'

systemd_unit 'vcan.service' do
  content <<-EOU.gsub(/^\s+/, '')
    [Unit]
    Description=Virtual CAN interface vcan0
    Requires=network.target
    After=network.target

    [Service]
    Type=oneshot
    RemainAfterExit=yes
    ExecStartPre=/sbin/modprobe vcan
    ExecStart=/sbin/ip link add dev vcan0 type vcan
    ExecStartPost=/sbin/ip link set up vcan0
    ExecStop=/sbin/ip link delete vcan0

    [Install]
    WantedBy=multi-user.target
  EOU
  action [:create, :enable, :start]
end
