#
# Cookbook:: boxcutter_users
# Recipe:: root
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

root_password = Boxcutter::OnePassword.op_read('op://Automation-Org/root/hash')

user 'root' do
  password root_password
  shell '/bin/bash'
  comment 'root'
  gid 'root'
  action :manage
end
