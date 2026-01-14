#
# Cookbook:: boxcutter_backhaul
# Recipe:: default
#
# Copyright:: 2024-present, Taylor.dev, LLC
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

nexus_hosts = %w{
  crake-nexus
}.include?(node['hostname'])

if nexus_hosts
  node.default['boxcutter_prometheus']['node_exporter']['command_line_flags'] = {
    'collector.systemd' => nil,
    'collector.processes' => nil,
    'no-collector.infiniband' => nil,
    'no-collector.nfs' => nil,
    'collector.textfile' => nil,
    'collector.textfile.directory' => '/var/lib/node_exporter/textfile',
    'web.listen-address' => ':9100',
  }

  include_recipe 'boxcutter_prometheus::node_exporter'

  storage_blob_store_name = 'default'
  node.default['boxcutter_sonatype']['nexus_repository']['repositories'] = {
    'ros-apt-proxy' => {
      'name' => 'ros-apt-proxy',
      'type' => 'proxy',
      'format' => 'apt',
      'storage_blob_store_name' => storage_blob_store_name,
      'proxy_remote_url' => 'http://packages.ros.org/ros2/ubuntu',
      'apt_distribution' => 'noble',
      'apt_flat' => false,
    },
    'ubuntu-archive-apt-proxy' => {
      'name' => 'ubuntu-archive-apt-proxy',
      'type' => 'proxy',
      'format' => 'apt',
      'storage_blob_store_name' => storage_blob_store_name,
      'proxy_remote_url' => 'http://archive.ubuntu.com/ubuntu',
      'apt_distribution' => 'noble',
      'apt_flat' => false,
    },
    'ubuntu-security-apt-proxy' => {
      'name' => 'ubuntu-security-apt-proxy',
      'type' => 'proxy',
      'format' => 'apt',
      'storage_blob_store_name' => storage_blob_store_name,
      'proxy_remote_url' => 'http://security.ubuntu.com/ubuntu/',
      'distribution' => 'noble',
      'flat' => false,
    },
    'ubuntu-ports-apt-proxy' => {
      'name' => 'ubuntu-ports-apt-proxy',
      'type' => 'proxy',
      'format' => 'apt',
      'storage_blob_store_name' => storage_blob_store_name,
      'proxy_remote_url' => 'http://ports.ubuntu.com/ubuntu-ports',
      'distribution' => 'noble',
      'flat' => false,
    },
    'grafana-oss-apt-proxy' => {
      'name' => 'grafana-oss-apt-proxy',
      'type' => 'proxy',
      'format' => 'apt',
      'storage_blob_store_name' => storage_blob_store_name,
      'proxy_remote_url' => 'https://packages.grafana.com/oss/deb',
      'distribution' => 'noble',
      'flat' => false,
    },
    'ubuntu-releases-proxy' => {
      'name' => 'ubuntu-releases-proxy',
      'type' => 'proxy',
      'format' => 'raw',
      'storage_blob_store_name' => storage_blob_store_name,
      'proxy_remote_url' => 'https://releases.ubuntu.com',
    },
    'ubuntu-cdimage-proxy' => {
      'name' => 'ubuntu-cdimage-proxy',
      'type' => 'proxy',
      'format' => 'raw',
      'storage_blob_store_name' => storage_blob_store_name,
      'proxy_remote_url' => 'https://cdimage.ubuntu.com',
    },
    'ubuntu-cloud-images-proxy' => {
      'name' => 'ubuntu-cloud-images-proxy',
      'type' => 'proxy',
      'format' => 'raw',
      'storage_blob_store_name' => storage_blob_store_name,
      'proxy_remote_url' => 'https://cloud-images.ubuntu.com',
    },
    'cinc-proxy' => {
      'name' => 'cinc-proxy',
      'type' => 'proxy',
      'format' => 'raw',
      'storage_blob_store_name' => storage_blob_store_name,
      'proxy_remote_url' => 'https://ftp.osuosl.org/pub/cinc',
    },
    'github-releases-proxy' => {
      'name' => 'github-releases-proxy',
      'type' => 'proxy',
      'format' => 'raw',
      'storage_blob_store_name' => storage_blob_store_name,
      'proxy_remote_url' => 'https://github.com',
    },
    'githubusercontent-proxy' => {
      'name' => 'githubusercontent-proxy',
      'type' => 'proxy',
      'format' => 'raw',
      'storage_blob_store_name' => storage_blob_store_name,
      'proxy_remote_url' => 'https://raw.githubusercontent.com',
    },
    'onepassword-proxy' => {
      'name' => 'onepassword-proxy',
      'type' => 'proxy',
      'format' => 'raw',
      'storage_blob_store_name' => storage_blob_store_name,
      'proxy_remote_url' => 'https://cache.agilebits.com',
    },
    'boxcutter-images-hosted' => {
      'name' => 'boxcutter-images-hosted',
      'type' => 'hosted',
      'format' => 'raw',
      'storage_blob_store_name' => storage_blob_store_name,
    },
    'docker-hosted' => {
      'name' => 'docker-hosted',
      'type' => 'hosted',
      'format' => 'docker',
      'storage_blob_store_name' => storage_blob_store_name,
      'docker_v1_enabled' => true,
      'docker_force_basic_auth' => true,
    },
    'docker-proxy' => {
      'name' => 'docker-proxy',
      'type' => 'proxy',
      'format' => 'docker',
      'storage_blob_store_name' => storage_blob_store_name,
      'proxy_remote_url' => 'https://registry-1.docker.io',
      'docker_v1_enabled' => true,
      'docker_force_basic_auth' => true,
      'docker_proxy_index_type' => 'HUB',
    },
    'docker' => {
      'name' => 'docker',
      'type' => 'group',
      'format' => 'docker',
      'storage_blob_store_name' => storage_blob_store_name,
      'group_member_names' => %w{
        docker-hosted
        docker-proxy
      },
      'group_writableMember' => 'docker-hosted',
      'docker_v1_enabled' => true,
      'docker_force_basic_auth' => true,
      'docker_http_port' => 8082,
    },
    'docker-cache-hosted' => {
      'name' => 'docker-cache-hosted',
      'type' => 'hosted',
      'format' => 'docker',
      'storage_blob_store_name' => storage_blob_store_name,
      'docker_v1_enabled' => true,
      'docker_force_basic_auth' => true,
    },
    'docker-cache' => {
      'name' => 'docker-cache',
      'type' => 'group',
      'format' => 'docker',
      'storage_blob_store_name' => storage_blob_store_name,
      'group_member_names' => %w{
        docker-cache-hosted
        docker-proxy
      },
      'group_writableMember' => 'docker-cache-hosted',
      'docker_v1_enabled' => true,
      'docker_force_basic_auth' => true,
      'docker_http_port' => 8083,
    },
    'pypi-proxy' => {
      'name' => 'pypi-proxy',
      'type' => 'proxy',
      'format' => 'pypi',
      'storage_blob_store_name' => storage_blob_store_name,
      'proxy_remote_url' => 'https://pypi.org/',
    },
  }

  # Set up an HTTP-only listener for ubuntu proxies because apt doesn't work
  # well with HTTPS
  node.default['fb_nginx']['sites']['nexus_http'] = {
    'listen' => '80',
    'server_name' => 'crake-nexus.org.boxcutter.net',
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
      'domains' => ['crake-nexus.org.boxcutter.net', '*.crake-nexus.org.boxcutter.net'],
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
    'server_name' => 'crake-nexus.org.boxcutter.net',
    'client_max_body_size' => '1G',
    'ssl_certificate' =>
      '/etc/letsencrypt/live/crake-nexus.org.boxcutter.net/fullchain.pem',
    'ssl_certificate_key' =>
      '/etc/letsencrypt/live/crake-nexus.org.boxcutter.net/privkey.pem',
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
    'server_name' => 'docker.crake-nexus.org.boxcutter.net',
    'client_max_body_size' => '0',
    'ssl_certificate' =>
      '/etc/letsencrypt/live/crake-nexus.org.boxcutter.net/fullchain.pem',
    'ssl_certificate_key' =>
      '/etc/letsencrypt/live/crake-nexus.org.boxcutter.net/privkey.pem',
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
    'server_name' => 'docker-cache.crake-nexus.org.boxcutter.net',
    'client_max_body_size' => '0',
    'ssl_certificate' =>
      '/etc/letsencrypt/live/crake-nexus.org.boxcutter.net/fullchain.pem',
    'ssl_certificate_key' =>
      '/etc/letsencrypt/live/crake-nexus.org.boxcutter.net/privkey.pem',
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
end
