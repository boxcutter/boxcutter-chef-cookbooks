default['boxcutter_grafana']['grafana'] = {
  'config' => {},
}

default['boxcutter_grafana']['loki'] = {
  'config' => {
    'auth_enabled' => false,
    'server' => {
      'http_listen_port' => 3100,
      'grpc_listen_port' => 9096,
      'log_level' => 'debug',
      'grpc_server_max_concurrent_streams' => 1000,
    },
    'common' => {
      'instance_addr' => '127.0.0.1',
      'path_prefix' => '/tmp/loki',
      'storage' => {
        'filesystem' => {
          'chunks_directory' => '/tmp/loki/chunks',
          'rules_directory' => '/tmp/loki/rules',
        },
      },
      'replication_factor' => 1,
      'ring' => {
        'kvstore' => {
          'store' => 'inmemory',
        },
      },
    },
    'query_range' => {
      'results_cache' => {
        'cache' => {
          'embedded_cache' => {
            'enabled' => true,
            'max_size_mb' => 100,
          },
        },
      },
    },
    'limits_config' => {
      'metric_aggregation_enabled' => true,
    },
    'schema_config' => {
      'configs' => [
        {
          'from' => '2020-10-24',
          'store' => 'tsdb',
          'object_store' => 'filesystem',
          'schema' => 'v13',
          'index' => {
            'prefix' => 'index_',
            'period' => '24h',
          },
        },
      ],
    },
    'pattern_ingester' => {
      'enabled' => true,
      'metric_aggregation' => {
        'loki_address' => 'localhost:3100',
      },
    },
    'ruler' => {
      'alertmanager_url' => 'http://localhost:9093',
    },
    'frontend' => {
      'encoding' => 'protobuf',
    },
    'analytics' => {
      'reporting_enabled' => false,
    },
  },
}