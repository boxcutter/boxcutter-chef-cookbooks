#
# Cookbook:: boxcutter_onepassword
# Recipe:: connect_server
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

connect_server_username = 'opuser'

node.default['fb_users']['users']['opuser'] = {
  'action' => :add,
  'home' => '/home/opuser',
  'shell' => '/bin/bash',
}

node.default['fb_users']['groups']['opuser'] = {
  'members' => ['opuser'],
  'action' => :add,
}

include_recipe 'boxcutter_docker'

node.default['fb_users']['groups']['docker']['members'] << 'opuser'

if node['boxcutter_onepassword'] &&
  node['boxcutter_onepassword']['connect_server'] &&
  node['boxcutter_onepassword']['connect_server']['onepassword_credentials'] &&
  !node['boxcutter_onepassword']['connect_server']['onepassword_credentials']['item'].nil?

  item = node['boxcutter_onepassword']['connect_server']['onepassword_credentials']['item']
  vault = node['boxcutter_onepassword']['connect_server']['onepassword_credentials']['vault']
  json_content = Boxcutter::OnePassword.op_document_get(item, vault, 'service_account')
end

node.default['boxcutter_docker']['bind_mounts']['onepassword_user'] = {
  'path' => '/home/opuser/.op',
  'owner' => connect_server_username,
  'group' => connect_server_username,
  'mode' => '0700',
}
node.default['boxcutter_docker']['bind_mounts']['onepassword_credentials'] = {
  'type' => 'file',
  'path' => '/home/opuser/.op/1password-credentials.json',
  'owner' => 999,
  'group' => 999,
  'content' => json_content,
  'mode' => '0600',
}
node.default['boxcutter_docker']['volumes']['onepassword_data'] = {
  'name' => 'onepassword_data',
}
node.default['boxcutter_docker']['containers']['op-connect-api'] = {
  'image' => '1password/connect-api:latest',
  'ports' => {
    '8080' => '8080',
  },
  'mounts' => {
    '1password_credentials' => {
      'type' => 'bind',
      'source' => '/home/opuser/.op/1password-credentials.json',
      'target' => '/home/opuser/.op/1password-credentials.json',
    },
    '1password_data' => {
      'source' => 'onepassword_data',
      'target' => '/home/opuser/.op/data',
    },
  },
  'logging_options' => {
    'max-size' => '50m',
    'max-file' => '10',
  },
  'extra_options' => {
    'restart' => 'always',
    'log-driver' => 'json-file',
  },
}
node.default['boxcutter_docker']['containers']['op-connect-sync'] = {
  'image' => '1password/connect-sync:latest',
  'ports' => {
    '8081' => '8080',
  },
  'mounts' => {
    '1password_credentials' => {
      'type' => 'bind',
      'source' => '/home/opuser/.op/1password-credentials.json',
      'target' => '/home/opuser/.op/1password-credentials.json',
    },
    '1password_data' => {
      'source' => 'onepassword_data',
      'target' => '/home/opuser/.op/data',
    },
  },
  'logging_options' => {
    'max-size' => '50m',
    'max-file' => '10',
  },
  'extra_options' => {
    'restart' => 'always',
    'log-driver' => 'json-file',
  },
}
