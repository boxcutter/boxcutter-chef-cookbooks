#
# Cookbook:: boxcutter_prometheus
# Recipe:: nvidia_gpu_exporter
#
# Copyright:: 2025, Boxcutter
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

include_recipe 'boxcutter_prometheus::user'

remote_file 'nvidia_gpu_exporter download' do
  path lazy {
         ::File.join(Chef::Config[:file_cache_path],
                     ::File.basename(node['boxcutter_prometheus']['nvidia_gpu_exporter']['source']))
       }
  source lazy { node['boxcutter_prometheus']['nvidia_gpu_exporter']['source'] }
  checksum lazy { node['boxcutter_prometheus']['nvidia_gpu_exporter']['checksum'] }
end

directory '/opt/nvidia_gpu_exporter' do
  owner 'root'
  group 'root'
  mode '0755'
end

archive_file 'nvidia_gpu_exporter.tar.gz' do
  path lazy {
         ::File.join(Chef::Config[:file_cache_path],
                     ::File.basename(node['boxcutter_prometheus']['nvidia_gpu_exporter']['source']))
       }
  destination lazy { "/opt/nvidia_gpu_exporter/#{node['boxcutter_prometheus']['nvidia_gpu_exporter']['creates']}" }
  owner 'root'
  group 'root'
end

link '/opt/nvidia_gpu_exporter/latest' do
  to lazy { "/opt/nvidia_gpu_exporter/#{node['boxcutter_prometheus']['nvidia_gpu_exporter']['creates']}" }
end

template '/etc/systemd/system/nvidia_gpu_exporter.service' do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'fb_systemd_reload[system instance]', :immediately
  notifies :restart, 'service[nvidia_gpu_exporter.service]'
end

service 'nvidia_gpu_exporter.service' do
  action [:enable, :start]
end
