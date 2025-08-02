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
