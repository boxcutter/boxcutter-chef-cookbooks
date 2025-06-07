#
# Cookbook:: boxcutter_prometheus_test
# Recipe:: postgresql
#

include_recipe 'boxcutter_postgresql::server'

# case node['kernel']['machine']
# when 'x86_64', 'amd64'
#   node.default['boxcutter_prometheus']['postgres_exporter']['source'] = \
#     'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus-community/postgres_exporter/releases/download/v0.17.1/postgres_exporter-0.17.1.linux-amd64.tar.gz'
#   node.default['boxcutter_prometheus']['postgres_exporter']['checksum'] = \
#     '6da7d2edafd69ecceb08addec876786fa609849f6d5f903987c0d61c3fc89506'
#   node.default['boxcutter_prometheus']['postgres_exporter']['creates'] = \
#     'postgres_exporter-0.17.1.linux-amd64'
# when 'aarch64', 'arm64'
#   node.default['boxcutter_prometheus']['postgres_exporter']['source'] = \
#     'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus-community/postgres_exporter/releases/download/v0.17.1/postgres_exporter-0.17.1.linux-arm64.tar.gz'
#   node.default['boxcutter_prometheus']['postgres_exporter']['checksum'] = \
#     '405af4e838a3d094d575e5aaeac43bd0a1818aaf2c840a3c8fc2c6fcc77218dc'
#   node.default['boxcutter_prometheus']['postgres_exporter']['creates'] = \
#     'postgres_exporter-0.17.1.linux-arm64'
# end

node.default['boxcutter_prometheus']['postgres_exporter']['environment'] = {
  'DATA_SOURCE_NAME' => 'postgresql:///postgres?host=/var/run/postgresql',
}

node.default['boxcutter_prometheus']['postgres_exporter']['command_line_flags'] = {
  'web.listen-address' => ':9187',
}

include_recipe 'boxcutter_prometheus::postgres_exporter'

node.default['boxcutter_prometheus']['prometheus']['config'] = {
  'global' => {
    'scrape_interval' => '15s',
  },
  'scrape_configs' => [
    {
      'job_name' => 'postgres_exporter',
      'static_configs' => [
        {
          'targets' => ['localhost:9187'],
        },
      ],
    },
  ],
}

node.default['boxcutter_prometheus']['prometheus']['alerting_rules'] = {
  'groups' => [
    {
      'name' => 'PostgreSQL',
      'rules' => [
        {
          'alert' => 'PostgreSQLMaxConnectionsReached',
          'expr' => 'sum(pg_stat_activity_count) by (instance) >= sum(pg_settings_max_connections) by (instance)' \
                    ' - sum(pg_settings_superuser_reserved_connections) by (instance)',
          'for' => '1m',
          'labels' => {
            'severity' => 'email',
          },
          'annotations' => {
            'summary' => '{{ $labels.instance }} has maxed out Postgres connections.',
            'description' => '{{ $labels.instance }} is exceeding the currently configured maximum Postgres' \
                             ' connection limit (current value: {{ $value }}s). Services may be degraded' \
                             ' - please take immediate action (you probably need to increase max_connections' \
                             ' in the Docker image and re-deploy.',
          },
        },
        {
          'alert' => 'PostgreSQLHighConnections',
          'expr' => 'sum(pg_stat_activity_count) by (instance) > (sum(pg_settings_max_connections) by (instance)' \
                    ' - sum(pg_settings_superuser_reserved_connections) by (instance)) * 0.8',
          'for' => '10m',
          'labels' => {
            'severity' => 'email',
          },
          'annotations' => {
            'summary' => '{{ $labels.instance }} is over 80% of max Postgres connections.',
            'description' => '{{ $labels.instance }} is exceeding 80% of the currently configured maximum Postgres' \
                             ' connection limit (current value: {{ $value }}s). Please check utilization graphs and' \
                             ' confirm if this is normal service growth, abuse or an otherwise temporary condition or' \
                             ' if new resources need to be provisioned (or the limits increased,' \
                             ' which is mostly likely).',
          },
        },
        {
          'alert' => 'PostgreSQLDown',
          'expr' => 'pg_up != 1',
          'for' => '1m',
          'labels' => {
            'severity' => 'email',
          },
          'annotations' => {
            'summary' => 'PostgreSQL is not processing queries: {{ $labels.instance }}',
            'description' => '{{ $labels.instance }} is rejecting query requests from the exporter,' \
                             ' and thus probably not allowing DNS requests to work either. User services' \
                             ' should not be effected provided at least 1 node is still alive.',
          },
        },
        {
          'alert' => 'PostgreSQLSlowQueries',
          'expr' => 'avg(rate(pg_stat_activity_max_tx_duration{datname!~"template.*"}[2m])) by (datname) > 2 * 60',
          'for' => '2m',
          'labels' => {
            'severity' => 'email',
          },
          'annotations' => {
            'summary' => 'PostgreSQL high number of slow on {{ $labels.cluster }} for database {{ $labels.datname }}',
            'description' => 'PostgreSQL high number of slow queries {{ $labels.cluster }}' \
                             ' for database {{ $labels.datname }} with a value of {{ $value }}',
          },
        },
        {
          'alert' => 'PostgreSQLQPS',
          'expr' => 'avg(irate(pg_stat_database_xact_commit{datname!~"template.*"}[5m])' \
                    ' + irate(pg_stat_database_xact_rollback{datname!~"template.*"}[5m])) by (datname) > 10000',
          'for' => '5m',
          'labels' => {
            'severity' => 'email',
          },
          'annotations' => {
            'summary' => 'PostgreSQL high number of queries per second {{ $labels.cluster }}' \
                         ' for database {{ $labels.datname }}',
            'description' => 'PostgreSQL high number of queries per second on {{ $labels.cluster }}' \
                             ' for database {{ $labels.datname }} with a value of {{ $value }}',
          },
        },
        {
          'alert' => 'PostgreSQLCacheHitRatio',
          'expr' => 'avg(rate(pg_stat_database_blks_hit{datname!~"template.*"}[5m])' \
                    ' / (rate(pg_stat_database_blks_hit{datname!~"template.*"}[5m])' \
                    ' + rate(pg_stat_database_blks_read{datname!~"template.*"}[5m]))) by (datname) < 0.98',
          'for' => '5m',
          'labels' => {
            'severity' => 'email',
          },
          'annotations' => {
            'summary' => 'PostgreSQL low cache hit rate on {{ $labels.cluster }} for database {{ $labels.datname }}',
            'description' => 'PostgreSQL low on cache hit rate on {{ $labels.cluster }}' \
                             ' for database {{ $labels.datname }} with a value of {{ $value }}',
          },
        },
      ],
    },
  ],
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

include_recipe 'fb_grafana'

# https://grafana.com/api/dashboards/14114/revisions/1/download

# su - postgres
# psql
# CREATE ROLE prometheus;
# GRANT pg_monitor to prometheus;
# \q
# sudo -u prometheus DATA_SOURCE_NAME="postgresql:///postgres?host=/var/run/postgresql" \
#   /opt/postgres_exporter/latest/postgres_exporter
