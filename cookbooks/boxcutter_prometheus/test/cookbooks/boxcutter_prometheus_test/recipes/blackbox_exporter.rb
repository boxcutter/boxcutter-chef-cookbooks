#
# Cookbook:: boxcutter_prometheus_test
# Recipe:: blackbox_exporter
#

case node['kernel']['machine']
when 'x86_64', 'amd64'
  node.default['boxcutter_prometheus']['blackbox_exporter']['source'] = \
    'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus/blackbox_exporter/releases/download/v0.26.0/blackbox_exporter-0.26.0.linux-amd64.tar.gz'
when 'aarch64', 'arm64'
  node.default['boxcutter_prometheus']['blackbox_exporter']['source'] = \
    'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus/blackbox_exporter/releases/download/v0.26.0/blackbox_exporter-0.26.0.linux-arm64.tar.gz'
end

node.default['boxcutter_prometheus']['blackbox_exporter']['config'] = {
  'modules' => {
    'http_2xx' => {
      'prober' => 'http',
      'timeout' => '5s',
      'http' => {
        'valid_status_codes' => [],
        'method' => 'GET',
      },
    },
  },
}

include_recipe 'boxcutter_prometheus::blackbox_exporter'

node.default['boxcutter_prometheus']['prometheus']['config'] = {
  'global' => {
    'scrape_interval' => '15s',
  },
  'scrape_configs' => [
    {
      'job_name' => 'blackbox',
      'metrics_path' => '/probe',
      'params' => {
        'module' => ['http_2xx'],
      },
      'static_configs' => [
        {
          'targets' => ['http://www.google.com'],
        },
      ],
      'relabel_configs' => [
        {
          'source_labels' => ['__address__'],
          'target_label' => '__param_target',
        },
        {
          'source_labels' => ['__param_target'],
          'target_label' => 'instance',
        },
        {
          'target_label' => '__address__',
          'replacement' => 'localhost:9115',
        },
      ],
    },
  ],
}

node.default['boxcutter_prometheus']['prometheus']['alerting_rules'] = {
  'groups' => [
    {
      'name' => 'alert.rules',
      'rules' => [
        {
          'alert' => 'EndpointDown',
          'expr' => 'probe_success == 0',
          'for' => '10s',
          'labels' => {
            'severity' => 'critical',
          },
          'annotations' => {
            'summary' => 'Endpoint {{ $labels.instance }} down',
          },
        },
      ],
    },
  ],
}

include_recipe 'boxcutter_prometheus::prometheus'
