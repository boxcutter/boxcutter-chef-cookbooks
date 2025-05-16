#
# Cookbook:: boxcutter_prometheus_test
# Recipe:: postgresql
#

include_recipe 'boxcutter_postgresql::server'

case node['kernel']['machine']
when 'x86_64', 'amd64'
  node.default['boxcutter_prometheus']['postgres_exporter']['source'] = \
    'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus-community/postgres_exporter/releases/download/v0.17.1/postgres_exporter-0.17.1.linux-amd64.tar.gz'
when 'aarch64', 'arm64'
  node.default['boxcutter_prometheus']['postgres_exporter']['source'] = \
    'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus-community/postgres_exporter/releases/download/v0.17.1/postgres_exporter-0.17.1.linux-arm64.tar.gz'
end

node.default['boxcutter_prometheus']['postgres_exporter']['environment'] = {
  'DATA_SOURCE_NAME' => 'postgresql:///postgres?host=/var/run/postgresql',
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

include_recipe 'boxcutter_prometheus::prometheus'

# su - postgres
# psql
# CREATE ROLE prometheus;
# GRANT pg_monitor to prometheus;
# \q
# sudo -u prometheus DATA_SOURCE_NAME="postgresql:///postgres?host=/var/run/postgresql" \
#   /opt/postgres_exporter/latest/postgres_exporter
