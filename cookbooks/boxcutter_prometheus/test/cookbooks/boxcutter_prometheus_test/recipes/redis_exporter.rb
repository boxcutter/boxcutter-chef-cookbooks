#
# Cookbook:: boxcutter_prometheus_test
# Recipe:: redis_exporter
#

# https://grafana.com/oss/prometheus/exporters/redis-exporter/
include_recipe 'boxcutter_redis::default'

# case node['kernel']['machine']
# when 'x86_64', 'amd64'
#   node.default['boxcutter_prometheus']['redis_exporter']['source'] = \
#     'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/oliver006/redis_exporter/releases/download/v1.73.0/redis_exporter-v1.73.0.linux-amd64.tar.gz'
#   node.default['boxcutter_prometheus']['redis_exporter']['checksum'] = \
#     '64a8902bf953095c5396349f289e17f7ce8f8f01e9f6859933344c260ccfd2f8'
#   node.default['boxcutter_prometheus']['redis_exporter']['creates'] = \
#     'redis_exporter-v1.73.0.linux-amd64'
# when 'aarch64', 'arm64'
#   node.default['boxcutter_prometheus']['redis_exporter']['source'] = \
#     'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/oliver006/redis_exporter/releases/download/v1.73.0/redis_exporter-v1.73.0.linux-arm64.tar.gz'
#   node.default['boxcutter_prometheus']['redis_exporter']['checksum'] = \
#     '1b802280742f40837f586509f3b5c528fa6196d3c21aaad4b13b0624de705acc'
#   node.default['boxcutter_prometheus']['redis_exporter']['creates'] = \
#     'redis_exporter-v1.73.0.linux-arm64'
# end

node.default['boxcutter_prometheus']['redis_exporter']['command_line_flags'] = {
  'web.listen-address' => ':9121',
}

include_recipe 'boxcutter_prometheus::redis_exporter'

node.default['boxcutter_prometheus']['prometheus']['config'] = {
  'global' => {
    'scrape_interval' => '15s',
  },
  'scrape_configs' => [
    {
      'job_name' => 'redis_exporter',
      'static_configs' => [
        {
          'targets' => ['localhost:9121'],
        },
      ],
    },
  ],
}

node.default['boxcutter_prometheus']['prometheus']['recording_rules'] = {
  'groups' => [
    {
      'name' => 'redis_rules',
      'rules' => [
        {
          'expr' => 'redis_memory_used_rss_bytes / redis_memory_used_bytes',
          'record' => 'redis_memory_fragmentation_ratio',
        },
      ],
    },
  ],
}

node.default['boxcutter_prometheus']['prometheus']['alerting_rules'] = {
  'groups' => [
    {
      'name' => 'redis',
      'rules' => [
        {
          'alert' => 'RedisDown',
          'annotations' => {
            'description' => "Redis instance is down\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}\n",
            'summary' => 'Redis down (instance {{ $labels.instance }})',
          },
          'expr' => 'redis_up == 0',
          'for' => '5m',
          'labels' => {
            'severity' => 'critical',
          },
        },
        {
          'alert' => 'RedisOutOfMemory',
          'annotations' => {
            'description' => "Redis is running out of memory (> 90%)\n" \
                             "  VALUE = {{ $value }}\n" \
                             "  LABELS: {{ $labels }}\n",
            'summary' => 'Redis out of memory (instance {{ $labels.instance }})',
          },
          'expr' => 'redis_memory_used_bytes / redis_total_system_memory_bytes * 100 > 90',
          'for' => '5m',
          'labels' => {
            'severity' => 'warning',
          },
        },
        {
          'alert' => 'RedisTooManyConnections',
          'annotations' => {
            'description' => "Redis instance has too many connections\n" \
                             "  VALUE = {{ $value }}\n" \
                             "  LABELS: {{ $labels }}\n",
            'summary' => 'Redis too many connections (instance {{ $labels.instance }})',
          },
          'expr' => 'redis_connected_clients > 100',
          'for' => '5m',
          'labels' => {
            'severity' => 'warning',
          },
        },
      ],
    },
  ],
}

include_recipe 'boxcutter_prometheus::prometheus'

include_recipe 'boxcutter_prometheus::alertmanager'

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

include_recipe 'fb_grafana'
# https://grafana.com/api/dashboards/14091/revisions/1/download
