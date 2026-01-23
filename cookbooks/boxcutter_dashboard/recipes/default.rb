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

dashboard_hosts = %w{
  crake-dashboard
}.include?(node['hostname'])

if dashboard_hosts
  node.default['fb_iptables']['filter']['INPUT']['rules']['prometheus'] = {
    'rule' => '-p tcp --dport 9090 -j ACCEPT',
  }

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
      {
        'job_name' => 'prometheus',
        'static_configs' => [
          {
            'targets' => ['localhost:9090'],
          }
        ]
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

  directory '/etc/prometheus/file_sd' do
    owner 'root'
    group 'root'
    mode '0755'
    recursive true
  end

  template '/etc/prometheus/file_sd/node_targets.yml' do
    source 'node_targets.yml.erb'
    owner 'root'
    group 'prometheus'
    mode '0644'
  end

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

  node.default['fb_nginx']['sites']['nexus'] = {
    'listen' => '80',
    # 'server_name' => 'dashboard.org.boxcutter.net',
    'server_name' => '_',
    'location /' => {
      'proxy_pass' => 'http://localhost:3000',
      # Preserve client info
      'proxy_set_header Host' => '$host',
      'proxy_set_header X-Real-IP' => '$remote_addr',
      'proxy_set_header X-Forwarded-For' => '$proxy_add_x_forwarded_for',
      'proxy_set_header X-Forwarded-Proto' => '$scheme',
      # WebSocket support (Grafana needs this)
      'proxy_http_version ' => '1.1',
      'proxy_set_header Upgrade' => '$http_upgrade',
      'proxy_set_header Connection' => '"upgrade"',
    },
  }

  include_recipe 'fb_nginx'
end
