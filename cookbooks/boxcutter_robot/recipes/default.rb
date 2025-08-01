#
# Cookbook:: boxcutter_robot
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

robot_hosts = %w{
  ubuntu-server-2404
  centos-stream-9
  centos-stream-10
}.include?(node['hostname'])

if robot_hosts
  case node['platform']
  when 'ubuntu'
    case node['kernel']['machine']
    when 'x86_64', 'amd64'
      package_info = value_for_platform(
        'ubuntu' => {
          '20.04' => {
            'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.7.10/ubuntu/20.04/cinc_18.7.10-1_amd64.deb',
            'checksum' => '40edbd9ed52cc1adaf09829a75e0d08e491728f6c0a9c3d6d9a3e3c1ddb8ceb8',
          },
          '22.04' => {
            'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.7.10/ubuntu/22.04/cinc_18.7.10-1_amd64.deb',
            'checksum' => '8870893d86a850df2f8c34a6ae85611ab786afe2425f0d5006a3da4397672946',
          },
          '24.04' => {
            'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.7.10/ubuntu/24.04/cinc_18.7.10-1_amd64.deb',
            'checksum' => '731b4757e8de4236db48c3672cb69693b9f7f66ea902f8c728990ec38a1fdc7d',
          },
        },
        )
    when 'aarch64', 'arm64'
      package_info = value_for_platform(
        'ubuntu' => {
          '20.04' => {
            'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.7.10/ubuntu/20.04/cinc_18.7.10-1_arm64.deb',
            'checksum' => 'db4305883055370d8f24ef6fe0b0936b8a654a771d35197b0af69333505038c4',
          },
          '22.04' => {
            'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.7.10/ubuntu/22.04/cinc_18.7.10-1_arm64.deb',
            'checksum' => '929dc59e9e0a25aff014e14f77bc20c36325bd16e0d660bfd9acd603a1676814',
          },
          '24.04' => {
            'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.7.10/ubuntu/24.04/cinc_18.7.10-1_arm64.deb',
            'checksum' => 'b103d3ddc9709b655874e71653bd78976ef601e35a0594baf669b617f21fad84',
          },
        },
        )
    end
  when 'centos'
    case node['kernel']['machine']
    when 'x86_64', 'amd64'
      package_info = value_for_platform(
        'centos' => {
          '9' => {
            'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.7.10/el/9/cinc-18.7.10-1.el9.x86_64.rpm',
            'checksum' => '78bc31f3a30605594b0f0eaf2523e94dc3525325bb04f5e3687d6cd7ee93b78e',
          },
          '10' => {
            'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.7.10/el/10/cinc-18.7.10-1.el10.x86_64.rpm',
            'checksum' => '026a7552f7adb69f4107952761db518df95dc0a28eaa290eacd3e79edceb9c7f',
          },
        },
        )
    when 'aarch64', 'arm64'
      package_info = value_for_platform(
        'centos' => {
          '9' => {
            'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.7.10/el/9/cinc-18.7.10-1.el9.aarch64.rpm',
            'checksum' => 'f97de13e17b8b7f5c4a00fd3f5db9b60ea63ff22d001c65ef011f39ba71e7aa6',
          },
          '10' => {
            'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.7.10/el/10/cinc-18.7.10-1.el10.aarch64.rpm',
            'checksum' => 'c479acc1f0e941a24538bf446360f8837d1f1076a6cbe860a447ab0b828a2fe0',
          },
        },
        )
    end
  end

  # node.default['boxcutter_chef']['cinc_client']['source'] = package_info['url']
  # node.default['boxcutter_chef']['cinc_client']['checksum'] = package_info['checksum']

  include_recipe 'boxcutter_ros'
  # package 'qemu-guest-agent'

  # include_recipe 'boxcutter_can::vcan'

  # whyrun_safe_ruby_block 'test' do
  #   block do
  #     case node['kernel']['machine']
  #     when 'x86_64', 'amd64'
  #       node.default['boxcutter_prometheus']['node_exporter']['source'] = \
  #         'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-amd64.tar.gz'
  #       node.default['boxcutter_prometheus']['node_exporter']['checksum'] = \
  #         'becb950ee80daa8ae7331d77966d94a611af79ad0d3307380907e0ec08f5b4e8'
  #       node.default['boxcutter_prometheus']['node_exporter']['creates'] = \
  #         'node_exporter-1.9.1.linux-amd64'
  #     when 'aarch64', 'arm64'
  #       node.default['boxcutter_prometheus']['node_exporter']['source'] = \
  #         'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-arm64.tar.gz'
  #       node.default['boxcutter_prometheus']['node_exporter']['checksum'] = \
  #         '848f139986f63232ced83babe3cad1679efdbb26c694737edc1f4fbd27b96203'
  #       node.default['boxcutter_prometheus']['node_exporter']['creates'] = \
  #         'node_exporter-1.9.1.linux-arm64'
  #     end
  #   end
  # end
  #
  # # https://grafana.com/oss/prometheus/exporters/node-exporter/
  # node.default['boxcutter_prometheus']['node_exporter']['command_line_flags'] = {
  #   'collector.systemd' => nil,
  #   'collector.processes' => nil,
  #   'no-collector.infiniband' => nil,
  #   'no-collector.nfs' => nil,
  #   'collector.textfile' => nil,
  #   'collector.textfile.directory' => '/var/lib/node_exporter/textfile',
  #   'web.listen-address' => ':9100',
  # }
  #
  # include_recipe 'boxcutter_prometheus::node_exporter'
end
