#
# Cookbook:: boxcutter_prometheus_test
# Recipe:: blackbox_exporter
#

# case node['kernel']['machine']
# when 'x86_64', 'amd64'
#   node.default['boxcutter_prometheus']['blackbox_exporter']['source'] = \
#     'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus/blackbox_exporter/releases/download/v0.26.0/blackbox_exporter-0.26.0.linux-amd64.tar.gz'
#   node.default['boxcutter_prometheus']['blackbox_exporter']['checksum'] = \
#     '4b1bb299c685ecff75d41e55e90aae8e02a658395fb14092c7f9c5c9d75016c7'
#   node.default['boxcutter_prometheus']['blackbox_exporter']['creates'] = \
#     'blackbox_exporter-0.26.0.linux-amd64'
# when 'aarch64', 'arm64'
#   node.default['boxcutter_prometheus']['blackbox_exporter']['source'] = \
#     'https://crake-nexus.org.boxcutter.net/repository/github-releases-proxy/prometheus/blackbox_exporter/releases/download/v0.26.0/blackbox_exporter-0.26.0.linux-arm64.tar.gz'
#   node.default['boxcutter_prometheus']['blackbox_exporter']['checksum'] = \
#     'afb5581b1d4ea45078eebc96e4f989f912d1144d2cc131db8a6c0963bcc6a654'
#   node.default['boxcutter_prometheus']['blackbox_exporter']['creates'] = \
#     'blackbox_exporter-0.26.0.linux-arm64'
# end

node.default['boxcutter_prometheus']['blackbox_exporter']['command_line_flags'] = {
  'web.listen-address' => ':9115',
}
node.default['boxcutter_prometheus']['blackbox_exporter']['config'] = {
  'modules' => {
    'http_2xx' => {
      'prober' => 'http',
      'timeout' => '5s',
      'http' => {
        'valid_http_versions' => ['HTTP/1.1', 'HTTP/2.0'],
        'valid_status_codes' => [], # Defaults to 2xx
        'method' => 'GET',
        'follow_redirects' => true,
        'fail_if_ssl' => false,
        'fail_if_not_ssl' => false,
        'fail_if_body_matches_regexp' => [],
        'fail_if_body_not_matches_regexp' => [],
        'tls_config' => {
          'insecure_skip_verify' => false,
        },
        'preferred_ip_protocol' => 'ip4', # defaults to "ip6"
        'ip_protocol_fallback' => false, # no fallback to "ip6"
      },
    },
    'ssl_cert' => {
      'prober' => 'tcp',
      'timeout' => '5s',
      'tcp' => {
        'tls' => true,
        'tls_config' => {
          'insecure_skip_verify' => true,
        },
      },
    },
    'icmp_ping' => {
      'prober' => 'icmp',
      'timeout' => '5s',
      'icmp' => {
        'preferred_ip_protocol' => 'ip4',
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
          'targets' => ['http://www.google.com', 'https://google.com'],
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

# https://grafana.com/grafana/dashboards/7587-prometheus-blackbox-exporter/
