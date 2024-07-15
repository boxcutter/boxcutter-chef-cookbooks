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

# file '' do
#   action :nothing
# end

ruby_block 'wait until nexus is ready' do
  block do
    result = false
    seconds_waited = 0
    seconds_sleep_interval = 10
    seconds_timeout = 300
    uri = URI.parse('http://127.0.0.1:8081/')
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
  action :run
end
