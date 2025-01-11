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

# nfs_server_hosts = %w{
#   nfs-server-centos-stream-9
#   nfs-server-ubuntu-2204
# }.include?(node['hostname'])
#
# if nfs_server_hosts
#   node.default['fb_iptables']['filter']['INPUT']['rules']['nfs server'] = {
#     'rules' => [
#       '-p tcp --dport 2049 -j ACCEPT',
#       '-p udp --dport 2049 -j ACCEPT',
#     ],
#   }
#
#   directory '/var/nfs' do
#     owner node.root_user
#     group node.root_group
#     mode '0755'
#   end
#
#   directory '/var/nfs/general' do
#     owner 'nobody'
#     group node.ubuntu? ? 'nogroup' : 'nobody'
#     mode '0777'
#   end
#
#   node.default['boxcutter_nfs']['server']['exports']['/var/nfs/general'] = %w{
#     *(rw,sync,no_subtree_check,insecure)
#   }
#
#   include_recipe 'boxcutter_nfs::server'
# end

nexus_hosts = %w{
  ip-10-0-1-51
}.include?(node['hostname'])

if nexus_hosts
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
  node.default['boxcutter_tailscale']['hostname'] = 'aws-boxcutter-nexus'
  node.default['boxcutter_tailscale']['tags'] = ['chef']
  include_recipe 'boxcutter_tailscale::default'

  node.default['boxcutter_sonatype']['nexus_repository']['blobstores'] = {
    's3-blob-store' => {
      'name' => 's3-blob-store',
      'type' => 's3',
      'bucket_region' => 'us-west-2',
      'bucket_name' => 'boxcutter-acceptance-blobstore-sandbox-uswest2',
    },
  }
  # storage_blob_store_name
  node.default['boxcutter_sonatype']['nexus_repository']['repositories'] = {
    'ros-apt-proxy' => {
      'name' => 'ros-apt-proxy',
      'type' => 'proxy',
      'format' => 'apt',
      'remote_url' => 'http://packages.ros.org/ros2/ubuntu',
      'distribution' => 'jammy',
      'flat' => false,
      'storage_blob_store_name' => 's3-blob-store',
    },
    'ubuntu-archive-apt-proxy' => {
      'name' => 'ubuntu-archive-apt-proxy',
      'type' => 'proxy',
      'format' => 'apt',
      'remote_url' => 'http://archive.ubuntu.com/ubuntu',
      'distribution' => 'jammy',
      'flat' => false,
      'storage_blob_store_name' => 's3-blob-store',
    },
    'ubuntu-security-apt-proxy' => {
      'name' => 'ubuntu-security-apt-proxy',
      'type' => 'proxy',
      'format' => 'apt',
      'remote_url' => 'http://security.ubuntu.com/ubuntu/',
      'distribution' => 'jammy',
      'flat' => false,
      'storage_blob_store_name' => 's3-blob-store',
    },
    'ubuntu-ports-apt-proxy' => {
      'name' => 'ubuntu-ports-apt-proxy',
      'type' => 'proxy',
      'format' => 'apt',
      'remote_url' => 'http://ports.ubuntu.com/ubuntu-ports',
      'distribution' => 'jammy',
      'flat' => false,
      'storage_blob_store_name' => 's3-blob-store',
    },
    'ubuntu-releases-proxy' => {
      'name' => 'ubuntu-releases-proxy',
      'type' => 'proxy',
      'format' => 'raw',
      'remote_url' => 'https://releases.ubuntu.com',
      'storage_blob_store_name' => 's3-blob-store',
    },
    'ubuntu-cdimage-proxy' => {
      'name' => 'ubuntu-cdimage-proxy',
      'type' => 'proxy',
      'format' => 'raw',
      'remote_url' => 'https://cdimage.ubuntu.com',
      'storage_blob_store_name' => 's3-blob-store',
    },
    'ubuntu-cloud-images-proxy' => {
      'name' => 'ubuntu-cloud-images-proxy',
      'type' => 'proxy',
      'format' => 'raw',
      'remote_url' => 'https://cloud-images.ubuntu.com',
      'storage_blob_store_name' => 's3-blob-store',
    },
    'cinc-proxy' => {
      'name' => 'cinc-proxy',
      'type' => 'proxy',
      'format' => 'raw',
      'remote_url' => 'https://ftp.osuosl.org/pub/cinc',
      'storage_blob_store_name' => 's3-blob-store',
    },
    'github-releases-proxy' => {
      'name' => 'github-releases-proxy',
      'type' => 'proxy',
      'format' => 'raw',
      'remote_url' => 'https://github.com',
      'storage_blob_store_name' => 's3-blob-store',
    },
    'githubusercontent-proxy' => {
      'name' => 'githubusercontent-proxy',
      'type' => 'proxy',
      'format' => 'raw',
      'remote_url' => 'https://raw.githubusercontent.com',
      'storage_blob_store_name' => 's3-blob-store',
    },
    'onepassword-proxy' => {
      'name' => 'onepassword-proxy',
      'type' => 'proxy',
      'format' => 'raw',
      'remote_url' => 'https://cache.agilebits.com',
      'storage_blob_store_name' => 's3-blob-store',
    },
    'boxcutter-images-hosted' => {
      'name' => 'boxcutter-images-hosted',
      'type' => 'hosted',
      'format' => 'raw',
      'storage_blob_store_name' => 's3-blob-store',
    },
    'docker-hosted' => {
      'name' => 'docker-hosted',
      'type' => 'hosted',
      'format' => 'docker',
      'docker_v1_enabled' => true,
      'docker_force_basic_auth' => true,
      'storage_blob_store_name' => 's3-blob-store',
    },
    'docker-proxy' => {
      'name' => 'docker-proxy',
      'type' => 'proxy',
      'format' => 'docker',
      'remote_url' => 'https://registry-1.docker.io',
      'docker_v1_enabled' => true,
      'docker_force_basic_auth' => true,
      'docker_proxy_index_type' => 'HUB',
      'storage_blob_store_name' => 's3-blob-store',
    },
    'docker' => {
      'name' => 'docker',
      'type' => 'group',
      'format' => 'docker',
      'member_names' => %w{
        docker-hosted
        docker-proxy
      },
      'writableMember' => 'docker-hosted',
      'docker_v1_enabled' => true,
      'docker_force_basic_auth' => true,
      'docker_http_port' => 8082,
      'storage_blob_store_name' => 's3-blob-store',
    },
    'docker-cache-hosted' => {
      'name' => 'docker-cache-hosted',
      'type' => 'hosted',
      'format' => 'docker',
      'docker_v1_enabled' => true,
      'docker_force_basic_auth' => true,
      'storage_blob_store_name' => 's3-blob-store',
    },
    'docker-cache' => {
      'name' => 'docker-cache',
      'type' => 'group',
      'format' => 'docker',
      'member_names' => %w{
        docker-cache-hosted
        docker-proxy
      },
      'writableMember' => 'docker-cache-hosted',
      'docker_v1_enabled' => true,
      'docker_force_basic_auth' => true,
      'docker_http_port' => 8083,
      'storage_blob_store_name' => 's3-blob-store',
    },
  }

  # Set up an HTTP-only listener for ubuntu proxies because apt doesn't work
  # well with HTTPS
  node.default['fb_nginx']['sites']['nexus_http'] = {
    'listen' => '80',
    'server_name' => 'aws-boxcutter-nexus.org.boxcutter.net',
    'location ~ ^/repository/' \
      '(ros-apt-proxy|' \
      'ubuntu-archive-apt-proxy|' \
      'ubuntu-security-apt-proxy|' \
      'ubuntu-ports-apt-proxy)/' => {
        'proxy_pass' => 'http://127.0.0.1:8081',
        'proxy_set_header Host' => '$host:80',
        'proxy_set_header X-Forwarded-For' => '$proxy_add_x_forwarded_for',
        'proxy_set_header X-Real-Ip' => '$remote_addr',
        'proxy_set_header X-Forwarded-Proto' => '$scheme',
      },
    # Redirect all other HTTP requests to HTTPS
    'location /' => {
      'return 301' => 'https://$host$request_uri',
    },
  }

  node.run_state['boxcutter_acme'] ||= {}
  node.run_state['boxcutter_acme']['certbot'] ||= {}
  node.run_state['boxcutter_acme']['certbot']['cloudflare_api_token'] = \
    Boxcutter::OnePassword.op_read('op://Automation-Org/Cloudflare API token amazing-sheila/credential')

  node.default['boxcutter_acme']['certbot']['config'] = {
    'nexus' => {
      'renew_script_path' => '/opt/certbot/bin/certbot_renew.sh',
      'certbot_bin' => '/opt/certbot/venv/bin/certbot',
      'domains' => ['aws-boxcutter-nexus.org.boxcutter.net', '*.aws-boxcutter-nexus.org.boxcutter.net'],
      'email' => 'letsencrypt@boxcutter.dev',
      'cloudflare_ini' => '/etc/chef/cloudflare.ini',
      'extra_args' => [
        '--dns-cloudflare',
        '--dns-cloudflare-credentials /etc/chef/cloudflare.ini',
      ].join(' '),
    },
  }

  include_recipe 'boxcutter_acme::certbot'

  node.default['fb_nginx']['enable_default_site'] = false
  node.default['fb_nginx']['config']['http']['proxy_send_timeout'] = '120'
  node.default['fb_nginx']['config']['http']['proxy_read_timeout'] = '300'
  node.default['fb_nginx']['config']['http']['proxy_buffering'] = 'off'
  node.default['fb_nginx']['config']['http']['proxy_request_buffering'] = 'off'
  node.default['fb_nginx']['config']['http']['keepalive_timeout'] = '5 5'
  node.default['fb_nginx']['config']['http']['tcp_nodelay'] = 'on'
  node.default['fb_nginx']['config']['http']['server_names_hash_bucket_size'] = '128'

  node.default['fb_nginx']['sites']['nexus'] = {
    'listen 443' => 'ssl',
    'server_name' => 'aws-boxcutter-nexus.org.boxcutter.net',
    'client_max_body_size' => '1G',
    'ssl_certificate' =>
      '/etc/letsencrypt/live/aws-boxcutter-nexus.org.boxcutter.net/fullchain.pem',
    'ssl_certificate_key' =>
      '/etc/letsencrypt/live/aws-boxcutter-nexus.org.boxcutter.net/privkey.pem',
    'location /' => {
      'proxy_set_header Host' => '$host:$server_port',
      'proxy_set_header X-Real-IP' => '$remote_addr',
      'proxy_set_header X-Forwarded-For' => '$proxy_add_x_forwarded_for',
      'proxy_set_header X-Forwarded-Proto' => '"https"',
      'proxy_pass' => 'http://127.0.0.1:8081',
    },
  }

  node.default['fb_nginx']['sites']['nexus_docker'] = {
    'listen 443' => 'ssl',
    'server_name' => 'docker.aws-boxcutter-nexus.org.boxcutter.net',
    'client_max_body_size' => '0',
    'ssl_certificate' =>
      '/etc/letsencrypt/live/aws-boxcutter-nexus.org.boxcutter.net/fullchain.pem',
    'ssl_certificate_key' =>
      '/etc/letsencrypt/live/aws-boxcutter-nexus.org.boxcutter.net/privkey.pem',
    'location ~ ^/(v1|v2)/[^/]+/?[^/]+/blobs/' => {
      'if ($request_method ~* (POST|PUT|DELETE|PATCH|HEAD) )' => {
        'rewrite ^/(.*)$ /repository/docker-hosted/$1' => 'last',
      },
      'rewrite ^/(.*)$ /repository/docker/$1' => 'last',
    },
    'location ~ ^/(v1|v2)/' => {
      'if ($request_method ~* (POST|PUT|DELETE|PATCH) )' => {
        'rewrite ^/(.*)$ /repository/docker-hosted/$1' => 'last',
      },
      'rewrite ^/(.*)$ /repository/docker/$1' => 'last',
    },
    'location /' => {
      'proxy_set_header Host' => '$host:$server_port',
      'proxy_set_header X-Real-IP' => '$remote_addr',
      'proxy_set_header X-Forwarded-For' => '$proxy_add_x_forwarded_for',
      'proxy_set_header X-Forwarded-Proto' => '"https"',
      'proxy_pass' => 'http://127.0.0.1:8081',
    },
  }

  node.default['fb_nginx']['sites']['nexus_docker_cache'] = {
    'listen 443' => 'ssl',
    'server_name' => 'docker-cache.aws-boxcutter-nexus.org.boxcutter.net',
    'client_max_body_size' => '0',
    'ssl_certificate' =>
      '/etc/letsencrypt/live/aws-boxcutter-nexus.org.boxcutter.net/fullchain.pem',
    'ssl_certificate_key' =>
      '/etc/letsencrypt/live/aws-boxcutter-nexus.org.boxcutter.net/privkey.pem',
    'location ~ ^/(v1|v2)/[^/]+/?[^/]+/blobs/' => {
      'if ($request_method ~* (POST|PUT|DELETE|PATCH|HEAD) )' => {
        'rewrite ^/(.*)$ /repository/docker-cache-hosted/$1' => 'last',
      },
      'rewrite ^/(.*)$ /repository/docker-cache/$1' => 'last',
    },
    'location ~ ^/(v1|v2)/' => {
      'if ($request_method ~* (POST|PUT|DELETE|PATCH) )' => {
        'rewrite ^/(.*)$ /repository/docker-cache-hosted/$1' => 'last',
      },
      'rewrite ^/(.*)$ /repository/docker-cache/$1' => 'last',
    },
    'location /' => {
      'proxy_set_header Host' => '$host:$server_port',
      'proxy_set_header X-Real-IP' => '$remote_addr',
      'proxy_set_header X-Forwarded-For' => '$proxy_add_x_forwarded_for',
      'proxy_set_header X-Forwarded-Proto' => '"https"',
      'proxy_pass' => 'http://127.0.0.1:8081',
    },
  }

  include_recipe 'fb_nginx'

  nexus_admin_username = Boxcutter::OnePassword.op_read(
    'op://Automation-Org/nexus admin blue/username',
    )
  nexus_admin_password = Boxcutter::OnePassword.op_read(
    'op://Automation-Org/nexus admin blue/password',
    )
  node.run_state['boxcutter_sonatype'] ||= {}
  node.run_state['boxcutter_sonatype']['nexus_repository'] ||= {}
  node.run_state['boxcutter_sonatype']['nexus_repository']['admin_username'] = nexus_admin_username
  node.run_state['boxcutter_sonatype']['nexus_repository']['admin_password'] = nexus_admin_password

  include_recipe 'boxcutter_sonatype::default'

  # node['boxcutter_docker']['buildkits']['x86_64_builder'] = {
  #   'name' => 'x86-64-builder',
  #   'use' => true,
  # }
  # node['boxcutter_docker']['contexts']['nvidia_jetson_agx_orin'] = {
  #   'name' => 'nvidia-jetson-agx-orin',
  #   'docker' => 'host=ssh://craft@10.63.34.15',
  # }
end
