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

SERVICE_CONFIG = {
}.freeze

FB::Users::UID_MAP.each do |user_name, desired_user_data|
  # root is never explicitly added via Chef, though it has an entry in
  # FB::Users, so ignore it
  next if user_name == node.root_user

  # If the user doesn't exist, then there can't be a conflict
  current_user_data = node['etc']['passwd'][user_name]
  next unless current_user_data

  if current_user_data['uid'].to_i != desired_user_data['uid'].to_i
    puts "MISCHA remap_users: user=#{user_name}: " \
      "current_uid=#{current_user_data['uid']}, " \
      "desired_uid=#{desired_user_data['uid']}"

    ruby_block "Fail if removing user #{user_name} and not adding back" do
      block do
        fail "boxcutter_site_settings::remap_users: User #{user_name} would be " \
          "removed, but not added back to node['fb_users']['users'], aborting."
      end
      not_if do
        node['fb_users']['users'][user_name]
      end
    end
  end
end

FB::Users::GID_MAP.each do |group_name, desired_group_data|
  # root is never explicitly added via Chef, though it has an entry in
  # FB::Users, so ignore it
  next if group_name == node.root_group

  # If the group doesn't exist, then there can't be a conflict
  current_group_data = node['etc']['group'][group_name]
  next unless current_group_data

  if current_group_data['gid'].to_i != desired_group_data['gid'].to_i
    puts "MISCHA remap_users: group=#{group_name}: " \
      "current_gid=#{current_group_data['gid']}, " \
      "desired_gid=#{desired_group_data['gid']}"

    ruby_block "Fail if removing group #{group_name} and not adding back" do
      block do
        fail "boxcutter_site_settings::remap_users: Group #{group_name} would be " \
               "removed, but not added back to node['fb_users']['groups'], aborting."
      end
      not_if do
        node['fb_users']['groups'][group_name]
      end
    end
  end
end
