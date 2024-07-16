#
# Cookbook:: boxcutter_sonatype
# Recipe:: nexus_docker
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

repository_data_directory = '/opt/sonatype/sonatype-work/nexus-data'
repository_url = 'http://127.0.0.1:8081'
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
  ],
}

include_recipe 'boxcutter_docker'

%w{
  /opt
  /opt/sonatype
  /opt/sonatype/sonatype-work
}.each do |path|
  node.default['boxcutter_docker']['bind_mounts'][path] = {
    'owner' => node.root_user,
    'group' => node.root_group,
    'mode' => '0755',
  }
end

node.default['boxcutter_docker']['bind_mounts']['nexus_data'] = {
  'path' => '/opt/sonatype/sonatype-work/nexus-data',
  'owner' => 200,
  'group' => 200,
  'mode' => '0755',
}

node.default['boxcutter_docker']['containers']['nexus3'] = {
  'image' => 'docker.io/sonatype/nexus3',
  'ports' => {
    # '127.0.0.1:8081' => '8081',
    '8081' => '8081',
  },
  'mounts' => {
    'nexus-data' => {
      'type' => 'bind',
      'source' => '/opt/sonatype/sonatype-work/nexus-data',
      'target' => '/nexus-data',
    },
  },
}

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
      rescue Errno::ECONNRESET, EOFError => e
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

node.default['fb_nginx']['sites']['artifactory'] = {
  'listen 443' => 'ssl',
  'server_name' => 'crake-artifactory-playpen.sandbox.boxcutter.net',
  'client_max_body_size' => '1G',
  'ssl' => 'on',
  'ssl_certificate' =>
    '/etc/lego/certificates/crake-artifactory-playpen.sandbox.boxcutter.net.crt',
  'ssl_certificate_key' =>
  '/etc/lego/certificates/crake-artifactory-playpen.sandbox.boxcutter.net.key',
  'location /' => {
    'proxy_pass' => 'http://127.0.0.1:8081',
    'proxy_set_header Host' => '$host',
    'proxy_set_header X-Real-IP' => '$remote_addr',
    'proxy_set_header X-Forwarded-For' => '$proxy_add_x_forwarded_for',
    'proxy_set_header X-Forwarded-Proto' => 'https',
  },
}
