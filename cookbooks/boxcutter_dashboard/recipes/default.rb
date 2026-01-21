#
# Cookbook:: boxcutter_dashboard
# Recipe:: default
#
# Copyright:: 2026-present, Taylor.dev, LLC
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

node.default['fb_iptables']['filter']['INPUT']['rules']['prometheus'] = {
  'rule' => '-p tcp --dport 9090 -j ACCEPT',
}

directory '/etc/prometheus' do
  owner 'root'
  group 'root'
  mode '0755'
end

directory '/etc/prometheus/file_sd' do
  owner 'root'
  group 'root'
  mode '0755'
end

template '/etc/prometheus/file_sd/node_targets.yml' do
  source 'node_targets.yml.erb'
  owner 'root'
  group 'prometheus'
  mode '0644'
end

node.default['boxcutter_prometheus']['prometheus']['config'] = {
  'global' => {
    'scrape_interval' => '60s',
  },
  'scrape_configs' => [
    {
      'job_name' => 'node',
      'file_sd_configs' => [
        {
          'files' => ['/etc/prometheus/file_sd/node_targets.yml'],
        },
      ],
    },
  ],
}

node.default['boxcutter_prometheus']['prometheus']['command_line_flags'] = {
  'storage.tsdb.path' => '/var/lib/prometheus/data',
  'storage.tsdb.retention.time' => '30d',
  'storage.tsdb.retention.size' => '20GB',
  'web.listen-address' => ':9090',
  'web.enable-remote-write-receiver' => nil,
}

include_recipe 'boxcutter_prometheus::prometheus'

node.default['fb_grafana']['datasources']['prometheus'] = {
  'type' => 'prometheus',
  'orgId' => 1,
  'url' => 'http://localhost:9090',
  'access' => 'proxy',
  'isDefault' => true,
  'editable' => false,
}

node.default['fb_grafana']['config'] = {
  'auth.anonymous' => {
    'enabled' => true,
    'org_name' => 'Main Org.',
    'org_role' => 'Admin',
  },
  'auth.basic' => {
    'enabled' => false,
  },
  'auth' => {
    'disable_login_form' => true,
  },
  'paths' => {
    'data' => '/var/lib/grafana',
    'logs' => '/var/log/grafana',
    'plugins' => '/var/lib/grafana/plugins',
  },
  'server' => {
    'protocol' => 'http',
    'http_port' => 3000,
  },
}

include_recipe 'fb_grafana::default'

directory '/etc/grafana/provisioning/dashboards/chef' do
  owner 'root'
  group 'grafana'
  mode '0755'
  recursive true
end

cookbook_file '/etc/grafana/provisioning/dashboards/chef/chef-metrics.json' do
  source 'chef-metrics.json'
  owner 'root'
  group 'grafana'
  mode '0644'
  notifies :restart, 'service[grafana-server]', :delayed
end

directory '/etc/grafana/provisioning/dashboards' do
  owner 'root'
  group 'grafana'
  mode '0755'
end

template '/etc/grafana/provisioning/dashboards/chef.yaml' do
  source 'dashboards/chef.yaml.erb'
  owner 'root'
  group 'grafana'
  mode '0644'
  notifies :restart, 'service[grafana-server]', :delayed
end
