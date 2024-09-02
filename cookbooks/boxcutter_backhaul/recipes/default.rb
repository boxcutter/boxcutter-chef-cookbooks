#
# Cookbook:: boxcutter_backhaul
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

nfs_server_hosts = %w{
  nfs-server-centos-stream-9
  nfs-server-ubuntu-2204
}.include?(node['hostname'])

if nfs_server_hosts
  node.default['fb_iptables']['filter']['INPUT']['rules']['nfs server'] = {
    'rules' => [
      '-p tcp --dport 2049 -j ACCEPT',
      '-p udp --dport 2049 -j ACCEPT',
    ],
  }

  directory '/var/nfs' do
    owner node.root_user
    group node.root_group
    mode '0755'
  end

  directory '/var/nfs/general' do
    owner 'nobody'
    group node.ubuntu? ? 'nogroup' : 'nobody'
    mode '0777'
  end

  node.default['boxcutter_nfs']['server']['exports']['/var/nfs/general'] = %w{
    *(rw,sync,no_subtree_check,insecure)
  }

  include_recipe 'boxcutter_nfs::server'
end

nexus_hosts = %w{
  crake-nexus
}.include?(node['hostname'])

if nexus_hosts
  cloudflare_api_token = Polymath::OnePassword.op_read('op://Automation-Org/Cloudflare API token amazing-sheila/credential')

  node.default['boxcutter_acme']['lego']['config'] = {
    'nexus' => {
      'certificate_name' => 'crake-nexus.org.boxcutter.net',
      'data_path' => '/etc/lego',
      'renew_script_path' => '/opt/lego/lego_renew.sh',
      'renew_days' => '30',
      'email' => 'letsencrypt@boxcutter.dev',
      'domains' => %w{
        crake-nexus.org.boxcutter.net
        *.crake-nexus.org.boxcutter.net
      },
      'extra_parameters' => [
        '--dns cloudflare',
        # There are issues resolving apex domain servers over tailscale, so
        # override the DNS resolver lego uses, in case we're running tailscale
        '--dns.resolvers 1.1.1.1',
      ],
      'extra_environment' => {
        'export CF_DNS_API_TOKEN' => cloudflare_api_token,
      },
    },
  }
end
