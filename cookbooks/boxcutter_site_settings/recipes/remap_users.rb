#
# Cookbook:: boxcutter_site_settings
# Recipe:: remap_users
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

FB::Users::UID_MAP.each do |user_name, desired_user_data|
  current_user_data = node['etc']['passwd'][user_name]
  next unless current_user_data

  if current_user_data['uid'].to_i != desired_user_data['uid'].to_i
    puts "MISCHA remap_users: user=#{user_name}: " \
      "current_uid=#{current_user_data['uid']}, " \
      "desired_uid=#{desired_user_data['uid']}"
  end
end

FB::Users::GID_MAP.each do |group_name, desired_group_data|
  current_group_data = node['etc']['group'][group_name]
  next unless current_group_data

  if current_group_data['gid'].to_i != desired_group_data['gid'].to_i
    puts "MISCHA remap_users: group=#{group_name}: " \
      "current_gid=#{current_group_data['gid']}, " \
      "desired_gid=#{desired_group_data['gid']}"
  end
end
