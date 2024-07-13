#
# Cookbook:: boxcutter_jfrog
# Recipe:: container_registry_docker
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

# Default interface is typically identified by having the default route
primary_interface = node['network']['default_interface']

# Get the IP address of the primary interface
primary_ip = node['network']['interfaces'][primary_interface]['addresses'].find do |_ip, params|
  params['family'] == 'inet'
end.first

# Print the IP address
Chef::Log.info("Primary IP address is #{primary_ip}")
puts "MISCHA: Primary IP address is #{primary_ip}"

node.default['fb_iptables']['filter']['INPUT']['rules']['jcr'] = {
  'rules' => [
    '-p tcp --dport 8081 -j ACCEPT',
    '-p tcp --dport 8082 -j ACCEPT',
  ],
}

include_recipe 'boxcutter_docker'

node.default['boxcutter_docker']['volumes']['postgres_data'] = {}
node.default['boxcutter_docker']['volumes']['artifactory_data'] = {}
node.default['boxcutter_docker']['networks']['artifactory_network'] = {}

node.default['boxcutter_docker']['containers']['postgresql'] = {
  'image' => 'releases-docker.jfrog.io/postgres:15.6-alpine',
  'environment' => {
    'POSTGRES_DB' => 'artifactory',
    'POSTGRES_USER' => 'artifactory',
    'POSTGRES_PASSWORD' => 'superseekret',
  },
  'ports' => {
    '5432' => '5432',
  },
  'mounts' => {
    'postgres_data' => {
      'source' => 'postgres_data',
      'target' => '/var/lib/postgresql/data',
    },
    'localtime' => {
      'type' => 'bind',
      'source' => '/etc/localtime',
      'target' => '/etc/localtime:ro',
    },
  },
  'ulimits' => {
    'nproc' => '65535',
    'nofile' => '32000:40000',
  },
  'logging_options' => {
    'max-size' => '50m',
    'max-file' => '10',
  },
  'extra_options' => {
    'restart' => 'always',
    'log-driver' => 'json-file',
    'network' => 'artifactory_network',
  },
}

node.default['boxcutter_docker']['containers']['artifactory'] = {
  'image' => 'releases-docker.jfrog.io/jfrog/artifactory-jcr:latest',
  'environment' => {
    'ENABLE_MIGRATION' => 'y',
    'JF_SHARED_DATABASE_TYPE' => 'postgresql',
    'JF_SHARED_DATABASE_USERNAME' => 'artifactory',
    'JF_SHARED_DATABASE_PASSWORD' => 'superseekret',
    'JF_SHARED_DATABASE_URL' => 'jdbc:postgresql://postgresql:5432/artifactory',
    'JF_SHARED_DATABASE_DRIVER' => 'org.postgresql.Driver',
    'JF_SHARED_NODE_IP' => primary_ip,
    # 'JF_SHARED_NODE_ID' => 'artifactory',
    # 'JF_SHARED_NODE_NAME' => 'artifactory',
    # 'JF_ROUTER_ENTRYPOINTS_EXTERNALPORT' => '8082',
  },
  'ports' => {
    '8081' => '8081',
    '8082' => '8082',
  },
  'mounts' => {
    'artifactory_data' => {
      'source' => 'artifactory_data',
      'target' => '/var/opt/jfrog/artifactory',
    },
    'localtime' => {
      'type' => 'bind',
      'source' => '/etc/localtime',
      'target' => '/etc/localtime:ro',
    },
  },
  'ulimits' => {
    'nproc' => '65535',
    'nofile' => '32000:40000',
  },
  'logging_options' => {
    'max-size' => '50m',
    'max-file' => '10',
  },
  'extra_options' => {
    'restart' => 'always',
    'log-driver' => 'json-file',
    'network' => 'artifactory_network',
  },
}

# curl -X GET -v http://localhost:8081/artifactory/api/v1/system/readiness
# curl -X GET -v http://localhost:8081/artifactory/api/v1/system/liveness

ruby_block 'wait until artifactory passes liveness check' do
  block do
    result = false
    seconds_waited = 0
    seconds_sleep_interval = 10
    seconds_timeout = 300
    uri = URI.parse('http://127.0.0.1:8081/artifactory/api/v1/system/liveness')
    loop do
      begin
        response = ::Net::HTTP.get_response(uri)
        puts "MISCHA: Got code #{response.code_type}"
        if response.code_type == Net::HTTPOK
          result = true
          break
        end
      rescue Errno::ECONNRESET, EOFError => e
        puts "MISCHA: Artifactory is not accepting requests - #{e.message}"
        puts "MISCHA: Artifactory is not accepting requests - #{e.inspect}"
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

# curl -x GET -v -u admin:password http://localhost:8081/artifactpry/api/system/license
# curl -XPOST -vu admin:password http://localhost:8081/artifactory/ui/jcr/eula/accept

http_request 'accept_eula' do
  url 'http://127.0.0.1:8081/artifactory/ui/jcr/eula/accept'
  headers({
            'Authorization' => "Basic #{Base64.encode64('admin:password').strip}",
            'Content-Type' => 'application/json',
          })
  message({}.to_json)
  action :nothing
end

payload = {
  userName: 'admin',
  oldPassword: 'password',
  newPassword1: 'Superseekret63',
  newPassword2: 'Superseekret63',
}
json_payload = payload.to_json

http_request 'change default admin password' do
  url 'http://127.0.0.1:8081/artifactory/api/security/users/authorization/changePassword'
  message json_payload
  headers({
            'Content-Type' => 'application/json',
            'Authorization' => "Basic #{Base64.encode64('admin:password').strip}",
          })
  action :nothing
end

file '/var/chef/.jfrog_container_registry_docker_configured' do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'ruby_block[wait until artifactory passes liveness check]', :immediately
  notifies :post, 'http_request[accept_eula]', :immediately
  notifies :post, 'http_request[change default admin password]', :immediately
end

include_recipe 'boxcutter_acme::lego'
