#
# Cookbook:: boxcutter_sonatype
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

node.run_state['boxcutter_sonatype'] ||= {}
node.run_state['boxcutter_sonatype']['nexus_repository'] ||= {}
node.run_state['boxcutter_sonatype']['nexus_repository']['admin_password'] = 'Superseekret63'

admin_password = node['boxcutter_sonatype']['nexus_repository']['admin_password']
if node.run_state.key?('boxcutter_sonatype') \
  && node.run_state['boxcutter_sonatype'].key?('nexus_repository') \
  && node.run_state['boxcutter_sonatype']['nexus_repository'].key?('admin_password')
  admin_password = node.run_state['boxcutter_sonatype']['nexus_repository']['admin_password']
end

node.default['fb_iptables']['filter']['INPUT']['rules']['nexus'] = {
  'rules' => [
    '-p tcp --dport 8081 -j ACCEPT',
    '-p tcp --dport 8082 -j ACCEPT',
    '-p tcp --dport 10080 -j ACCEPT',
    '-p tcp --dport 10443 -j ACCEPT',
  ],
}

directory '/opt/sonatype' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

# https://help.sonatype.com/en/download.html
version = 'nexus-3.71.0-06'
url = 'https://download.sonatype.com/nexus/3/nexus-3.71.0-06-unix.tar.gz'
checksum = 'b025287558184677fc231035c9f5e5e6cc4bc1cafd76d13a06233a4ed09d08f6'

tmp_path = ::File.join(Chef::Config[:file_cache_path], ::File.basename(url))

remote_file tmp_path do
  source url
  checksum checksum
end

path = ::File.join('/opt/sonatype', version)

execute 'extract nexus' do
  command <<-BASH
    tar --exclude='sonatype-work*' --extract --directory '/opt/sonatype' --file #{tmp_path}
    chown -R nexus:nexus '/opt/sonatype/nexus-3.71.0-06'
  BASH
  creates '/opt/sonatype/nexus-3.71.0-06/bin/nexus'
end

link '/opt/sonatype/nexus' do
  to path.to_s
end

directory '/opt/sonatype/nexus/nexus3' do
  recursive true
  action :delete
end

directory '/nexus-data' do
  owner 'nexus'
  group 'nexus'
  mode '0755'
  recursive true
  action :create
end

directory '/nexus-data/etc' do
  owner 'nexus'
  group 'nexus'
  mode '0755'
  recursive true
  action :create
end

directory '/nexus-data/log' do
  owner 'nexus'
  group 'nexus'
  mode '0755'
  recursive true
  action :create
end

directory '/nexus-data/tmp' do
  owner 'nexus'
  group 'nexus'
  mode '0755'
  recursive true
  action :create
end

directory '/opt/sonatype/sonatype-work' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

link '/opt/sonatype/sonatype-work/nexus3' do
  to '/nexus-data'
  owner 'root'
  group 'root'
end

node.default['boxcutter_java']['sdkman'] = {
  '/opt/sonatype/nexus/.sdkman' => {
    'user' => 'nexus',
    'group' => 'nexus',
    'candidates' => {
      'java' => '17.0.12-tem',
    },
  },
}

FB::Users.initialize_group(node, 'nexus')
node.default['fb_users']['users']['nexus'] = {
  'home' => '/opt/sonatype/nexus',
  'gid' => 'nexus',
  'shell' => '/bin/bash',
  'manage_home' => false,
  'action' => :add,
}

include_recipe 'boxcutter_java::default'

template '/opt/sonatype/start-nexus-repository-manager.sh' do
  source 'start-nexus-repository-manager.sh.erb'
  owner 'root'
  group 'root'
  mode '0755'
end

systemd_unit 'nexus-repository-manager.service' do
  content <<-EOU.gsub(/^\s+/, '')
  [Unit]
  Description=Nexus Repository Manager service
  After=network.target
  [Service]
  Type=simple
  LimitNOFILE=65536
  ExecStart=/opt/sonatype/start-nexus-repository-manager.sh
  User=nexus
  Restart=on-failure
  StartLimitInterval=30min
  StartLimitBurst=2
  [Install]
  WantedBy=multi-user.target
  EOU
  action [:create, :enable, :start]
end

repository_data_directory = '/opt/sonatype/sonatype-work/nexus3'
repository_url = 'http://127.0.0.1:8081'

ruby_block 'wait until nexus is ready' do
  block do
    result = false
    seconds_waited = 0
    seconds_sleep_interval = 10
    seconds_timeout = 300
    uri = URI.parse(repository_url)
    loop do
      begin
        response = ::Net::HTTP.get_response(uri)
        puts "MISCHA: Got code #{response.code_type}"
        if response.code_type == Net::HTTPOK
          result = true
          break
        end
      rescue Errno::ECONNRESET, Errno::ECONNREFUSED, EOFError => e
        puts "MISCHA: Nexus is not accepting requests - #{e.message}"
        puts "MISCHA: Nexus is not accepting requests - #{e.inspect}"
        nil
      end
      break if seconds_waited > seconds_timeout
      sleep(seconds_sleep_interval)
      seconds_waited += seconds_sleep_interval
    end

    result
  end
  action :nothing
end

template ::File.join(repository_data_directory, 'nexus.properties') do
  source 'nexus.properties.erb'
  owner 200
  group 200
  mode '0644'
  notifies :run, 'ruby_block[wait until nexus is ready]', :immediately
end

# OLD_PASSWORD=$(cat '/opt/sonatype/sonatype-work/nexus-data/admin.password')
# curl -ifu admin:"${OLD_PASSWORD}" \
#   -XPUT -H 'Content-Type: text/plain' \
#   --data "${NEW_PASSWORD}" \
#   http://127.0.0.1:8081/service/rest/v1/security/users/admin/change-password
admin_password_path = ::File.join(repository_data_directory, 'admin.password')

file admin_password_path do
  action :nothing
end

http_request 'change admin password' do
  url lazy { "#{repository_url}/service/rest/v1/security/users/admin/change-password" }
  headers lazy {
    {
      'Content-Type' => 'text/plain',
      'Authorization' => "Basic #{Base64.encode64("admin:#{::File.read(admin_password_path)}").strip}",
    }
  }
  message lazy { admin_password }
  action :put
  only_if { ::File.exist?(admin_password_path) }
  notifies :run, 'ruby_block[wait until nexus is ready]', :immediately
  notifies :delete, "file[#{admin_password_path}]", :immediately
  notifies :put, 'http_request[enable_anonymous_user]', :immediately
  # notifies :put, 'http_request[disable_telemetry]', :immediately
end

# verify:
# curl -u <username>:<password> http://<nexus-url>/service/rest/v1/security/anonymous
#
# curl -u ${NEXUS_USERNAME}:${NEXUS_PASSWORD} \
#   -X PUT \
#   -H 'Content-Type: application/json' \
#   -d '{ "enabled": true, "userId": "anonymous" }' \
#   http://127.0.0.1:8081/service/rest/v1/security/anonymous
#
# curl -u <username>:<password> \
#   -X PUT \
#   -H "Content-Type: application/json" \
#   -d '{"enabled": false}' \
#   http://<nexus-url>/service/rest/v1/security/anonymous

http_request 'enable_anonymous_user' do
  url lazy { "#{repository_url}/service/rest/v1/security/anonymous" }
  headers({
            'Content-Type' => 'application/json',
            'Authorization' => "Basic #{Base64.encode64("admin:#{admin_password}").strip}",
          })
  message '{ "enabled": true, "userId": "anonymous" }'
  action :nothing
end

# curl -u <username>:<password> \
#   -X PUT -H "Content-Type: application/json" \
#   -d '{"enabled":false}' http://<nexus-url>/service/rest/v1/telemetry/status

# http_request 'disable_telemetry' do
#   url lazy { "#{repository_url}/service/rest/v1/telemetry/status" }
#   headers({
#             'Content-Type' => 'application/json',
#             'Authorization' => "Basic #{Base64.encode64("admin:#{admin_password}").strip}"
#           })
#   message '{"enabled":false}'
#   action :nothing
# end

include_recipe 'boxcutter_acme::lego'
include_recipe 'fb_nginx'

node.default['fb_nginx']['enable_default_site'] = false
node.default['fb_nginx']['config']['http']['proxy_send_timeout'] = '120'
node.default['fb_nginx']['config']['http']['proxy_read_timeout'] = '300'
node.default['fb_nginx']['config']['http']['proxy_buffering'] = 'off'
node.default['fb_nginx']['config']['http']['proxy_request_buffering'] = 'off'
node.default['fb_nginx']['config']['http']['keepalive_timeout'] = '5 5'
node.default['fb_nginx']['config']['http']['tcp_nodelay'] = 'on'

node.default['fb_nginx']['sites']['nexus'] = {
  'listen 10443' => 'ssl',
  # 'server_name' => 'hq0-nexus01.sandbox.polymathrobotics.dev',
  'server_name' => node['ipaddress'],
  'client_max_body_size' => '1G',
  'ssl_certificate' => '/etc/nginx/nexus.crt',
  'ssl_certificate_key' => '/etc/nginx/nexus.key',
  '_create_self_signed_cert' => true,
  # 'ssl_certificate' =>
  #   '/etc/lego/certificates/hq0-nexus01.sandbox.polymathrobotics.dev.crt',
  # 'ssl_certificate_key' =>
  #   '/etc/lego/certificates/hq0-nexus01.sandbox.polymathrobotics.dev.key',
  'location /' => {
    'proxy_pass' => 'http://127.0.0.1:8081',
    'proxy_set_header Host' => '$host:10443',
    'proxy_set_header X-Real-IP' => '$remote_addr',
    'proxy_set_header X-Forwarded-For' => '$proxy_add_x_forwarded_for',
    'proxy_set_header X-Forwarded-Proto' => 'https',
  },
}

node.default['fb_nginx']['sites']['nexus_docker'] = {
  'listen 5000' => 'default_server',
  'ssl' => 'on',
  'server_name' => node['ipaddress'],
  'ssl_certificate' => '/etc/nginx/nexus.crt',
  'ssl_certificate_key' => '/etc/nginx/nexus.key',
  '_create_self_signed_cert' => true,
  # optimize downloading files larger than 1G
  'proxy_max_temp_file_size' => '2048m',
  'location /' => {
    'proxy_pass' => 'http://127.0.0.1:8082',
    'proxy_set_header Host' => '$host:5000',
    'proxy_set_header X-Forwarded-Proto' => 'https',
    'proxy_set_header X-Forwarded-For' => '$proxy_add_x_forwarded_for',
    'proxy_set_header X-Real-Ip' => '$remote_addr',
  },
}

boxcutter_sonatype_nexus_repository 'configure'
