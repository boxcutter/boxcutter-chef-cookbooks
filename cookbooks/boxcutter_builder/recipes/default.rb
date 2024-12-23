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

package 'jq'

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
          'emily-arm64-runner' => {
            'name' => 'emily-arm64-runner',
            'endpoint' => 'host=ssh://craft@emily-arm64-builder.org.boxcutter.net',
            'platform' => 'linux/arm64,linux/arm/v7,linux/arm/v6',
          },
        },
      },
    },
  }

  node.default['boxcutter_github']['github_runner'] = {
    'runners' => {
      '/home/github-runner/actions-runner' => {
        'runner_name' => node['hostname'],
        'url' => 'https://github.com/boxcutter/oci',
        'labels' => ['multi-arch'],
        # self-hosted Linux X64
        'owner' => 'github-runner',
        'group' => 'github-runner',
      },
    },
  }

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

  node.default['fb_ssh']['authorized_keys']['craft']['boxcutter_craft'] = craft_ssh_public_key
  node.default['fb_ssh']['authorized_keys']['craft']['bettyanne_build_rsa_ssh_key_private'] = \
    'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDIxMXLhDmYHv7llUu00Xa+092jJwg0TncimyGpSP56UYtZKIZKuvm' +
    'dnxgLwcS5HxShJ7p/Ilw67mUPqGGiA+8mCM4UC3WTetPrNYwYAQlJ96+l023DE8fQ7eNkpBFKDixlNphWlsvMFdFGqJ' +
    'xIdk7U3wRJY6a9NKUB3UupUrSz+oBxCaU7jzMmH1wgUSoCa++F9A3ekUY4kDcVMJAZT4lS63FDHoTRhdgAnFA+MeYc6' +
    'tQ14YFvj+8O6qp8Aqt/ppqsKJjNGTC2K1iOC1M2mq9W0cmPLT3O3+uD7YSlhFYKXYEKUdTVtyooDICOUVagH7tkXKed' +
    'bv2nKKIw3/gbFBaYvVOq/kckqouZQC6L/m+z7A4zpBvd7dyIeufJAJQwb1E/uHmy+mesz8+e5viTIXwnCDSkRvW4l9F' +
    'sGkXweydWPmscvdcBdbGXUWI7OEOGAYOWVgQpAJ0RJ5WtLhXAnfZ/HBojq+c014eq7O/oL2ZyxpUp74w9WrhsFV/mzV' +
    'cJA+JWO9+0W9qU1MYhyPWXar9QUfJl1ny0zYQD5O7yZEHEhV5LCkXSapCG3B80ofIBs4yr18WBGxUCyDmXW+6Budtm9' +
    'U2CaBfBdsEESj2kuYOCEMo9IJB+k5b0BCycPqBFoRPTYzISCGrpE0ro6BPSv3YNsv+cR/LT7njM1onXiOe/vw=='

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

if node.aws?
  aws_arm64_github_self_hosted_runner_list = [
    'ip-10-0-1-70', # arm64 builder
  ]

  if aws_arm64_github_self_hosted_runner_list.include?(node['hostname'])
    include_recipe 'boxcutter_users::default'
    include_recipe 'boxcutter_docker::default'

    include_recipe 'boxcutter_github::runner_user'
    node.default['fb_users']['groups']['docker']['members'] << 'github-runner'
    node.default['fb_ssh']['authorized_keys_users'] << 'github-runner'

    node.default['fb_ssh']['authorized_keys']['github-runner']['aws-arm64-github-runner'] = \
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
    'ip-10-0-1-237', # x86-64 builder
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

    include_recipe 'boxcutter_users::default'
    include_recipe 'boxcutter_docker::default'

    include_recipe 'boxcutter_github::runner_user'
    node.default['fb_users']['groups']['docker']['members'] << 'github-runner'
    node.default['fb_ssh']['authorized_keys_users'] << 'github-runner'

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
    end

    # arm64 builder
    ssh_known_hosts_entry '10.0.1.70' do
      file_location '/home/github-runner/.ssh/known_hosts'
      owner 'github-runner'
      group 'github-runner'
    end

    node.default['polymath_docker']['buildx']['github-runner'] = {
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
            '10.0.1.70' => {
              'name' => '10.0.1.70',
              'endpoint' => 'host=ssh://github-runner@10.0.1.70',
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
