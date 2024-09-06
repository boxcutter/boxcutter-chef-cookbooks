#
# Cookbook:: boxcutter_builder
# Recipe:: default
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

amd64_self_hosted_runner_list = %w{
  crake-amd64-builder
}

if amd64_self_hosted_runner_list.include?(node['hostname'])
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

  include_recipe 'boxcutter_docker::default'
  FB::Users.initialize_group(node, 'docker')

  include_recipe 'boxcutter_builder::user'
end

# arm64_self_hosted_runner_list = %w{
#   agx01-builder-tegra
# }

# if arm64_self_hosted_runner_list.include?(node['hostname'])
# end
