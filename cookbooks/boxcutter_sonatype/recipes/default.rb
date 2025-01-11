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

install_root = node['boxcutter_sonatype']['nexus_repository']['install_root']
# Default: /opt/sonatype
directory install_root do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

# https://help.sonatype.com/en/download.html
version = 'nexus-3.76.0-03'
url = 'https://download.sonatype.com/nexus/3/nexus-3.76.0-03-unix.tar.gz'
checksum = 'd336a1c1fa3c26ee977ef720707d7bbca660aee5bf7369a9037293910c63c672'

tmp_path = ::File.join(Chef::Config[:file_cache_path], ::File.basename(url))

remote_file tmp_path do
  source url
  checksum checksum
end

nexus_version_path = ::File.join(install_root, version)

# The install tar.gz includes a skeleton `sonatype-work` directory to create
# an empty data directory. Ignore this path, as we'll manage this in Chef.
#
# This sonatype-work tree doesn't have any content, it's just a skeleton:
# ls -alR sonatype-work/nexus3/
# sonatype-work/nexus3/:
# total 16
# drwxr-xr-x 4 root root 4096 Aug 21 20:09 .
# drwxr-xr-x 3 root root 4096 Aug 21 20:09 ..
# -rw-r--r-- 1 root root    0 Aug  8 16:52 clean_cache
# drwxr-xr-x 2 root root 4096 Aug 21 20:09 log
# drwxr-xr-x 2 root root 4096 Aug 21 20:09 tmp
#
# sonatype-work/nexus3/log:
# total 8
# drwxr-xr-x 2 root root 4096 Aug 21 20:09 .
# drwxr-xr-x 4 root root 4096 Aug 21 20:09 ..
# -rw-r--r-- 1 root root    0 Aug  8 16:52 .placeholder
#
# sonatype-work/nexus3/tmp:
# total 8
# drwxr-xr-x 2 root root 4096 Aug 21 20:09 .
# drwxr-xr-x 4 root root 4096 Aug 21 20:09 ..
# -rw-r--r-- 1 root root    0 Aug  8 16:52 .placeholder
execute 'extract nexus' do
  command <<-BASH
    tar --exclude='sonatype-work*' --extract --directory '#{install_root}' --file #{tmp_path}
    chown -R nexus:nexus '#{nexus_version_path}'
  BASH
  # Default: /opt/sonatype/nexus/bin/nexus
  creates ::File.join(nexus_version_path, 'bin', 'nexus')
end

# /opt/sonatype/nexus
nexus_home = ::File.join(install_root, 'nexus')
link nexus_home do
  to nexus_version_path.to_s
end

# /opt/sonatype/sonatype-work/nexus3
data_path = node['boxcutter_sonatype']['nexus_repository']['data_path']

[
  data_path,
  ::File.join(data_path, 'etc'),
  ::File.join(data_path, 'log'),
  ::File.join(data_path, 'tmp'),
].each do |dir|
  directory dir do
    owner 'nexus'
    group 'nexus'
    mode '0755'
    recursive true
    action :create
  end
end

# template ::File.join(nexus_home, 'bin', 'nexus.vmoptions') do
#   source 'nexus.properties.erb'
#   owner 200
#   group 200
#   mode '0644'
#   variables(
#     properties: node['boxcutter_sonatype']['nexus_repository']['runtime']['properties'],
#   )
# end

template ::File.join(data_path, 'etc', 'nexus.properties') do
  source 'nexus.properties.erb'
  owner 200
  group 200
  mode '0644'
  variables(
    properties: node['boxcutter_sonatype']['nexus_repository']['runtime']['properties'],
  )
end

node.default['boxcutter_java']['sdkman'] = {
  ::File.join(nexus_home, '.sdkman') => {
    'user' => 'nexus',
    'group' => 'nexus',
    'candidates' => {
      'java' => {
        '17.0.12-tem' => nil,
      },
    },
  },
}

FB::Users.initialize_group(node, 'nexus')
node.default['fb_users']['users']['nexus'] = {
  # /opt/sonatype/nexus
  'home' => nexus_home,
  'gid' => 'nexus',
  'shell' => '/bin/bash',
  'manage_home' => false,
  'action' => :add,
}

include_recipe 'boxcutter_java::default'

start_nexus_script = ::File.join(install_root, 'start-nexus-repository-manager.sh')
template start_nexus_script do
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
  ExecStart=#{start_nexus_script}
  User=nexus
  Restart=on-failure
  StartLimitInterval=30min
  StartLimitBurst=2
  [Install]
  WantedBy=multi-user.target
  EOU
  action [:create, :enable, :start]
end

# repository_data_directory = '/opt/sonatype/sonatype-work/nexus3'
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

template ::File.join(data_path, 'nexus.properties') do
  source 'nexus.properties.erb'
  owner 200
  group 200
  mode '0644'
  variables(
    properties: node['boxcutter_sonatype']['nexus_repository']['properties'],
  )
  notifies :run, 'ruby_block[wait until nexus is ready]', :immediately
end

if node['boxcutter_sonatype']['nexus_repository']['manage_admin']
  # OLD_PASSWORD=$(cat '/opt/sonatype/sonatype-work/nexus-data/admin.password')
  # curl -ifu admin:"${OLD_PASSWORD}" \
  #   -XPUT -H 'Content-Type: text/plain' \
  #   --data "${NEW_PASSWORD}" \
  #   http://127.0.0.1:8081/service/rest/v1/security/users/admin/change-password
  admin_password_path = ::File.join(data_path, 'admin.password')

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
    action :nothing
    # only_if { ::File.exist?(admin_password_path) }
  end

  http_request 'enable_anonymous_user' do
    url lazy { "#{repository_url}/service/rest/v1/security/anonymous" }
    headers({
              'Content-Type' => 'application/json',
              'Authorization' => "Basic #{Base64.encode64("admin:#{admin_password}").strip}",
            })
    message '{ "enabled": true, "userId": "anonymous" }'
    action :nothing
  end

  file '/var/chef/.sonatype_nexus_configured' do
    owner 'root'
    group 'root'
    mode '0644'
    notifies :run, 'ruby_block[wait until nexus is ready]', :immediately
    notifies :put, 'http_request[change admin password]', :immediately
    notifies :delete, "file[#{admin_password_path}]", :immediately
    notifies :put, 'http_request[enable_anonymous_user]', :immediately
  end
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

# http_request 'enable_anonymous_user' do
#   url lazy { "#{repository_url}/service/rest/v1/security/anonymous" }
#   headers({
#             'Content-Type' => 'application/json',
#             'Authorization' => "Basic #{Base64.encode64("admin:#{admin_password}").strip}",
#           })
#   message '{ "enabled": true, "userId": "anonymous" }'
#   action :nothing
# end

boxcutter_sonatype_nexus_repository 'configure'
