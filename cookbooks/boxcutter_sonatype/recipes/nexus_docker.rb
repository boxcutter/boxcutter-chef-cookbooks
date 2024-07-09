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

%w(
  /opt
  /opt/sonatype
  /opt/sonatype/sonatype-work
).each do |path|
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
    }
  }
}

# ruby_block 'wait until nexus ready' do
#   block do
#     uri = URI.parse('http://127.0.0.1:8081/')
#     Timeout.timeout(5 * 60, Timeout::Error) do
#       begin
#         response = ::Net::HTTP.get_response(uri)
#         response.error! if response.code.start_with?('5')
#       rescue SocketError,
#         EOFError,
#         Errno::ECONNREFUSED,
#         Errno::ECONNRESET,
#         Errno::ENETUNREACH,
#         Errno::EADDRNOTAVAIL,
#         Errno::EHOSTUNREACH,
#         Net::HTTPError => e
#         puts "MISCHA: Nexus is not accepting requests - #{e.message}"
#         sleep 1
#         retry
#       end
#     rescue Timeout::Error
#       raise 'Nexus did not become ready - timeout'
#     end
#   end
#   action :run
# end
