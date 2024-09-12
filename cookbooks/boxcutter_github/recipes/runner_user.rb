#
# Cookbook:: boxcutter_github
# Recipe:: runner_user
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

node.default['fb_users']['users']['github-runner'] = {
  'action' => :add,
  'home' => '/home/github-runner',
  'shell' => '/bin/bash',
  'gid' => 'github-runner'
}

node.default['fb_users']['groups']['github-runner'] = {
  'members' => ['github-runner'],
  'action' => :add,
}
