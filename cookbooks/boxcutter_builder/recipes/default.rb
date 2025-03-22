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

  node.default['polymath_docker']['enable_cleanup'] = false

  # include_recipe 'boxcutter_users::default'
  include_recipe 'boxcutter_docker::default'

  include_recipe 'boxcutter_github::runner_user'
  node.default['fb_users']['groups']['docker']['members'] << 'github-runner'

  directory '/home/github-runner/.ssh' do
    owner 'github-runner'
    group 'github-runner'
    mode '0700'
  end

  craft_rsa_ssh_key_private = \
    Boxcutter::OnePassword.op_read('op://Automation-Org/craft SSH Key/private key')

  file '/home/github-runner/.ssh/id_rsa' do
    owner 'github-runner'
    group 'github-runner'
    mode '0600'
    content craft_rsa_ssh_key_private
  end

  ssh_known_hosts_entry 'github.com' do
    file_location '/home/github-runner/.ssh/known_hosts'
    owner 'github-runner'
    group 'github-runner'
    mode '0600'
  end

  # arm64 builder
  # ssh_known_hosts_entry '10.0.1.175' do
  #   file_location '/home/github-runner/.ssh/known_hosts'
  #   owner 'github-runner'
  #   group 'github-runner'
  #   mode '0600'
  # end

  node.default['boxcutter_docker']['buildx']['github-runner'] = {
    'home' => '/home/github-runner',
    'user' => 'github-runner',
    'group' => 'github-runner',
    'builders' => {
      'github-runner-multi-arch-builder' => {
        'name' => 'github-runner-multi-arch-builder',
        'driver' => 'docker-container',
        # 'platform' => 'linux/amd64,linux/amd64/v2,linux/amd64/v3,linux/amd64/v4,linux/386',
        'use' => true,
        # 'append' => {
        #   '10.0.1.175' => {
        #     'name' => '10.0.1.175',
        #     'endpoint' => 'host=ssh://github-runner@10.0.1.175',
        #     'platform' => 'linux/arm64,linux/arm/v7,linux/arm/v6',
        #   },
        # },
      },
    },
  }

  directory '/home/github-runner/actions-runner' do
    owner 'github-runner'
    group 'github-runner'
    mode '0700'
  end

  %w{
    oci
  }.each do |dir|
    directory "/home/github-runner/actions-runner/#{dir}" do
      owner 'github-runner'
      group 'github-runner'
      mode '0700'
    end

    node.default['boxcutter_github']['github_runner']['runners']["/home/github-runner/actions-runner/#{dir}"] = {
      'runner_name' => node['hostname'],
      'labels' => ['self-hosted', 'multi-arch'],
      'url' => "https://github.com/boxcutter/#{dir}",
      'owner' => 'github-runner',
      'group' => 'github-runner',
    }
  end

  include_recipe 'boxcutter_github::cli'
  include_recipe 'boxcutter_github::runner'
end

if node.aws?
  aws_arm64_github_self_hosted_runner_list = [
    'ip-10-0-1-175', # arm64 builder
  ]

  if aws_arm64_github_self_hosted_runner_list.include?(node['hostname'])
    # op item get 'tailscale oauth automation-sandbox-write-blue' --vault Automation-Sandbox
    # op item get v5zvz2gomyzhgow46esj7txneu --format json
    tailscale_oauth_client_id_write_blue =\
      Boxcutter::OnePassword.op_read('op://Automation-Org/tailscale oauth write blue/username')
    tailscale_oauth_client_secret_write_blue = \
      Boxcutter::OnePassword.op_read('op://Automation-Org/tailscale oauth write blue/credential')
    node.run_state['boxcutter_tailscale'] ||= {}
    node.run_state['boxcutter_tailscale']['oauth_client_id'] = tailscale_oauth_client_id_write_blue
    node.run_state['boxcutter_tailscale']['oauth_client_secret'] = tailscale_oauth_client_secret_write_blue
    node.default['boxcutter_tailscale']['enable'] = true
    node.default['boxcutter_tailscale']['ephemeral'] = false
    node.default['boxcutter_tailscale']['use_tailscale_dns'] = false
    node.default['boxcutter_tailscale']['shields_up'] = false
    node.default['boxcutter_tailscale']['hostname'] = 'aws-boxcutter-arm64-github-runner'
    node.default['boxcutter_tailscale']['tags'] = ['chef']
    include_recipe 'boxcutter_tailscale::default'

    node.default['polymath_docker']['enable_cleanup'] = false
    # include_recipe 'boxcutter_users::default'
    include_recipe 'boxcutter_docker::default'

    include_recipe 'boxcutter_github::runner_user'
    node.default['fb_users']['groups']['docker']['members'] << 'github-runner'

    node.default['fb_ssh']['authorized_keys']['github-runner']['craft'] = \
      Boxcutter::OnePassword.op_read('op://Automation-Org/craft SSH Key/public key')

    directory '/home/github-runner/.ssh' do
      owner 'github-runner'
      group 'github-runner'
      mode '0700'
    end

    ssh_known_hosts_entry 'github.com' do
      file_location '/home/github-runner/.ssh/known_hosts'
      owner 'github-runner'
      group 'github-runner'
      mode '0600'
    end

    craft_rsa_ssh_key_private = \
      Boxcutter::OnePassword.op_read('op://Automation-Org/craft SSH Key/private key')

    file '/home/github-runner/.ssh/id_rsa' do
      owner 'github-runner'
      group 'github-runner'
      mode '0600'
      content craft_rsa_ssh_key_private
    end
  end

  aws_amd64_github_self_host_runner_list = [
    'ip-10-0-1-71', # x86-64 builder
  ]

  if aws_amd64_github_self_host_runner_list.include?(node['hostname'])
    # op item get 'tailscale oauth automation-sandbox-write-blue' --vault Automation-Sandbox
    # op item get v5zvz2gomyzhgow46esj7txneu --format json
    tailscale_oauth_client_id_write_blue =\
      Boxcutter::OnePassword.op_read('op://Automation-Org/tailscale oauth write blue/username')
    tailscale_oauth_client_secret_write_blue = \
      Boxcutter::OnePassword.op_read('op://Automation-Org/tailscale oauth write blue/credential')
    node.run_state['boxcutter_tailscale'] ||= {}
    node.run_state['boxcutter_tailscale']['oauth_client_id'] = tailscale_oauth_client_id_write_blue
    node.run_state['boxcutter_tailscale']['oauth_client_secret'] = tailscale_oauth_client_secret_write_blue
    node.default['boxcutter_tailscale']['enable'] = true
    node.default['boxcutter_tailscale']['ephemeral'] = false
    node.default['boxcutter_tailscale']['use_tailscale_dns'] = false
    node.default['boxcutter_tailscale']['shields_up'] = false
    node.default['boxcutter_tailscale']['hostname'] = 'aws-boxcutter-amd64-github-runner'
    node.default['boxcutter_tailscale']['tags'] = ['chef']
    include_recipe 'boxcutter_tailscale::default'

    node.default['polymath_docker']['enable_cleanup'] = false

    # include_recipe 'boxcutter_users::default'
    include_recipe 'boxcutter_docker::default'

    include_recipe 'boxcutter_github::runner_user'
    node.default['fb_users']['groups']['docker']['members'] << 'github-runner'

    directory '/home/github-runner/.ssh' do
      owner 'github-runner'
      group 'github-runner'
      mode '0700'
    end

    craft_rsa_ssh_key_private = \
      Boxcutter::OnePassword.op_read('op://Automation-Org/craft SSH Key/private key')

    file '/home/github-runner/.ssh/id_rsa' do
      owner 'github-runner'
      group 'github-runner'
      mode '0600'
      content craft_rsa_ssh_key_private
    end

    ssh_known_hosts_entry 'github.com' do
      file_location '/home/github-runner/.ssh/known_hosts'
      owner 'github-runner'
      group 'github-runner'
      mode '0600'
    end

    # arm64 builder
    ssh_known_hosts_entry '10.0.1.175' do
      file_location '/home/github-runner/.ssh/known_hosts'
      owner 'github-runner'
      group 'github-runner'
      mode '0600'
    end

    node.default['boxcutter_docker']['buildx']['github-runner'] = {
      'home' => '/home/github-runner',
      'user' => 'github-runner',
      'group' => 'github-runner',
      'builders' => {
        'github-runner-multi-arch-builder' => {
          'name' => 'github-runner-multi-arch-builder',
          'driver' => 'docker-container',
          'platform' => 'linux/amd64,linux/amd64/v2,linux/amd64/v3,linux/amd64/v4,linux/386',
          'use' => true,
          'append' => {
            '10.0.1.175' => {
              'name' => '10.0.1.175',
              'endpoint' => 'host=ssh://github-runner@10.0.1.175',
              'platform' => 'linux/arm64,linux/arm/v7,linux/arm/v6',
            },
          },
        },
      },
    }

    directory '/home/github-runner/actions-runner' do
      owner 'github-runner'
      group 'github-runner'
      mode '0700'
    end

    %w{
      oci
    }.each do |dir|
      directory "/home/github-runner/actions-runner/#{dir}" do
        owner 'github-runner'
        group 'github-runner'
        mode '0700'
      end

      node.default['boxcutter_github']['github_runner']['runners']["/home/github-runner/actions-runner/#{dir}"] = {
        'runner_name' => node['hostname'],
        'labels' => ['self-hosted', 'multi-arch'],
        'url' => "https://github.com/boxcutter/#{dir}",
        'owner' => 'github-runner',
        'group' => 'github-runner',
      }
    end

    include_recipe 'boxcutter_github::cli'
    include_recipe 'boxcutter_github::runner'
  end
end

arm64_self_hosted_runner_list = %w{
  agx01-builder-tegra
}

if arm64_self_hosted_runner_list.include?(node['hostname'])
  package 'jq'

  node.default['polymath_docker']['enable_cleanup'] = false

  include_recipe 'boxcutter_docker::default'

  include_recipe 'boxcutter_github::runner_user'
  node.default['fb_users']['groups']['docker']['members'] << 'github-runner'

  directory '/home/github-runner/.ssh' do
    owner 'github-runner'
    group 'github-runner'
    mode '0700'
  end

  craft_rsa_ssh_key_private = \
    Boxcutter::OnePassword.op_read('op://Automation-Org/craft SSH Key/private key')

  file '/home/github-runner/.ssh/id_rsa' do
    owner 'github-runner'
    group 'github-runner'
    mode '0600'
    content craft_rsa_ssh_key_private
  end

  ssh_known_hosts_entry 'github.com' do
    file_location '/home/github-runner/.ssh/known_hosts'
    owner 'github-runner'
    group 'github-runner'
    mode '0600'
  end
end

new_amd64_self_hosted_runner_list = %w{
  nancy-amd64-builder
}

if new_amd64_self_hosted_runner_list.include?(node['hostname'])
  package 'jq'

  node.default['polymath_docker']['enable_cleanup'] = false

  include_recipe 'boxcutter_docker::default'

  include_recipe 'boxcutter_github::runner_user'
  node.default['fb_users']['groups']['docker']['members'] << 'github-runner'

  directory '/home/github-runner/.ssh' do
    owner 'github-runner'
    group 'github-runner'
    mode '0700'
  end

  craft_rsa_ssh_key_private = \
    Boxcutter::OnePassword.op_read('op://Automation-Org/craft SSH Key/private key')

  file '/home/github-runner/.ssh/id_rsa' do
    owner 'github-runner'
    group 'github-runner'
    mode '0600'
    content craft_rsa_ssh_key_private
  end

  ssh_known_hosts_entry 'github.com' do
    file_location '/home/github-runner/.ssh/known_hosts'
    owner 'github-runner'
    group 'github-runner'
    mode '0600'
  end

  # arm64 builder
  ssh_known_hosts_entry '10.67.127.109' do
    file_location '/home/github-runner/.ssh/known_hosts'
    owner 'github-runner'
    group 'github-runner'
    mode '0600'
  end
end
