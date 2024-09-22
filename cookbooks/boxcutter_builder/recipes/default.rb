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
  package 'jq'

  include_recipe 'boxcutter_docker::default'
  FB::Users.initialize_group(node, 'docker')

  include_recipe 'boxcutter_builder::user'
  node.default['fb_users']['groups']['docker']['members'] << 'craft'

  # node.default['boxcutter_docker']['buildx']['craft'] = {
  #   'home' => '/home/craft',
  #   'user' => 'craft',
  #   'group' => 'craft',
  #   'builders' => {
  #     'multi-arch-builder' => {
  #       'name' => 'multi-arch-builder',
  #       'driver' => 'docker-container',
  #       'use' => true,
  #       'append' => {
  #         'emily-arm64-builder' => {
  #           'name' => 'emily-arm64-builder',
  #           'endpoint' => 'host=ssh://craft@emily-arm64-builder.org.boxcutter.net'
  #         }
  #       }
  #     },
  #   },
  # }

  # include_recipe 'boxcutter_can::vcan'
  # include_recipe 'fb_networkd'

  include_recipe 'boxcutter_github::runner_user'
  include_recipe 'boxcutter_github::cli'

  node.default['fb_users']['groups']['docker']['members'] << 'github-runner'

  craft_ssh_private_key = Boxcutter::OnePassword.op_read('op://Automation-Org/craft SSH Key/private key')
  craft_ssh_public_key = Boxcutter::OnePassword.op_read('op://Automation-Org/craft SSH Key/public key')

  directory '/home/github-runner/.ssh' do
    owner 'github-runner'
    group 'github-runner'
    mode '0700'
  end

  file '/home/github-runner/.ssh/id_rsa' do
    content craft_ssh_private_key
    owner 'github-runner'
    group 'github-runner'
    mode '0600'
  end

  file '/home/github-runner/.ssh/id_rsa.pub' do
    content craft_ssh_public_key
    owner 'github-runner'
    group 'github-runner'
    mode '0655'
  end

  ssh_known_hosts_entry 'emily-arm64-builder.org.boxcutter.net' do
    file_location '/home/github-runner/.ssh/known_hosts'
    owner 'github-runner'
    group 'github-runner'
  end

  # node.default['boxcutter_docker']['buildx']['github-runner'] = {
  #   'home' => '/home/github-runner',
  #   'user' => 'github-runner',
  #   'group' => 'github-runner',
  #   'builders' => {
  #     'x86_64_builder' => {
  #       'name' => 'github-runner-x86-64-builder',
  #       'driver' => 'docker-container',
  #       'platform' => 'linux/amd64,linux/amd64/v2,linux/amd64/v3,linux/amd64/v4,linux/386',
  #       'use' => true,
  #       'append' => {
  #         'github_runner_nvidia_jetson_agx_orin' => {
  #           'name' => 'github-runner-nvidia-jetson-agx-orin',
  #           'endpoint' => 'host=ssh://craft@10.63.33.102',
  #           'platform' => 'linux/arm64,linux/arm/v7,linux/arm/v6',
  #         },
  #       },
  #     },
  #   },
  # }

  # node.default['boxcutter_github']['github_runner'] = {
  #   'runners' => {
  #     '/home/github-runner/actions-runner' => {
  #       'runner_name' => node['hostname'],
  #       'url' => 'https://github.com/boxcutter/oci',
  #       'owner' => 'github-runner',
  #       'group' => 'github-runner',
  #     },
  #   },
  # }

  include_recipe 'boxcutter_github::runner'
end

tegra_self_hosted_runner_list = %w{
  agx01
}

if tegra_self_hosted_runner_list.include?(node['hostname'])
  package 'jq'

  include_recipe 'boxcutter_nvidia::l4t'
  include_recipe 'boxcutter_ubuntu_desktop'

  node.default['boxcutter_docker']['config']['runtimes']['nvidia'] = {
    'path' => 'nvidia-container-runtime',
    'args' => [],
  }
  include_recipe 'boxcutter_docker::default'
  FB::Users.initialize_group(node, 'docker')

  include_recipe 'boxcutter_builder::user'
  node.default['fb_users']['groups']['docker']['members'] << 'craft'
end

arm64_self_hosted_runner_list = %w{
  emily-arm64-builder
}

if arm64_self_hosted_runner_list.include?(node['hostname'])
  include_recipe 'boxcutter_docker::default'
  FB::Users.initialize_group(node, 'docker')

  include_recipe 'boxcutter_builder::user'
  node.default['fb_users']['groups']['docker']['members'] << 'craft'

  # node.default['boxcutter_docker']['buildx']['craft'] = {
  #   'home' => '/home/craft',
  #   'user' => 'craft',
  #   'group' => 'craft',
  #   'builders' => {
  #     'multi-arch-builder' => {
  #       'name' => 'multi-arch-builder',
  #       'driver' => 'docker-container',
  #       'use' => true,
  #       'append' => {
  #         'emily-arm64-builder' => {
  #           'name' => 'emily-arm64-builder',
  #           'endpoint' => 'host=ssh://craft@emily-arm64-builder.org.boxcutter.net'
  #         }
  #       }
  #     },
  #   },
  # }
end
