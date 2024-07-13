#
# Cookbook:: boxcutter_site_settings
# Recipe:: ssh
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

{
  'ChallengeResponseAuthentication' => false,
  'GSSAPIAuthentication' => false,
  'HostbasedAuthentication' => false,
  'KerberosAuthentication' => false,
  'LoginGraceTime' => '60',
  'PasswordAuthentication' => false,
  'PrintMotd' => false,
  'PubkeyAuthentication' => true,
  'StrictModes' => true,
  'TCPKeepAlive' => true,
  'UseDNS' => false,
  'UsePAM' => true,
  'X11Forwarding' => true,
}.each do |key, val|
  node.default['fb_ssh']['sshd_config'][key] = val
end

node.default['fb_ssh']['authorized_keys']['root'] = root_keys
node.default['fb_ssh']['authorized_keys_users'] << 'root'
