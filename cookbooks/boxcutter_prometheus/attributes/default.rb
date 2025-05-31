case node['kernel']['machine']
when 'x86_64', 'amd64'
  prometheus_source = 'https://github.com/prometheus/prometheus/releases/download/v3.3.1/prometheus-3.3.1.linux-amd64.tar.gz'
  prometheus_checksum = 'e22600b314f65fd180fe17c0afeea85ed8484e924fc589c2331b084813699ef0'
  prometheus_creates = 'prometheus-3.3.1.linux-amd64'
when 'aarch64', 'arm64'
  prometheus_source = 'https://github.com/prometheus/prometheus/releases/download/v3.3.1/prometheus-3.3.1.linux-arm64.tar.gz'
  prometheus_checksum = '6e3b24c13c55bb2f0e05248327276e6ad6e96ceea4865296a41cbbc092dd45ea'
  prometheus_creates = 'prometheus-3.3.1.linux-arm64'
end

default['boxcutter_prometheus']['prometheus'] = {
  'enable' => true,
  'source' => prometheus_source,
  'checksum' => prometheus_checksum,
  'creates' => prometheus_creates,
  'config' => {
    'global' => {
      'scrape_interval' => '60s',
    },
    'scrape_configs' => {},
    'remote_write' => {},
  },
  'alerting_rules' => {},
  'recording_rules' => {},
  'command_line_flags' => {
    'storage.tsdb.path' => '/var/lib/prometheus/data',
    'storage.tsdb.retention.time' => '30d',
    'storage.tsdb.retention.size' => '20GB',
  },
}

case node['kernel']['machine']
when 'x86_64', 'amd64'
  alertmanager_source = 'https://github.com/prometheus/alertmanager/releases/download/v0.28.1/alertmanager-0.28.1.linux-amd64.tar.gz'
  alertmanager_checksum = '5ac7ab5e4b8ee5ce4d8fb0988f9cb275efcc3f181b4b408179fafee121693311'
  alertmanager_creates = 'alertmanager-0.28.1.linux-amd64'
when 'aarch64', 'arm64'
  alertmanager_source = 'https://github.com/prometheus/alertmanager/releases/download/v0.28.1/alertmanager-0.28.1.linux-arm64.tar.gz'
  alertmanager_checksum = 'd8832540e5b9f613d2fd759e31d603173b9c61cc7bb5e3bc7ae2f12038b1ce4f'
  alertmanager_creates = 'alertmanager-0.28.1.linux-arm64'
end

default['boxcutter_prometheus']['alertmanager'] = {
  'source' => alertmanager_source,
  'checksum' => alertmanager_checksum,
  'creates' => alertmanager_creates,
  'config' => {},
  'command_line_flags' => {
    'storage.path' => '/var/lib/alertmanager/data',
  },
}

case node['kernel']['machine']
when 'x86_64', 'amd64'
  pushgateway_source = 'https://github.com/prometheus/pushgateway/releases/download/v1.11.1/pushgateway-1.11.1.linux-amd64.tar.gz'
  pushgateway_checksum = '6ce6ffab84d0d71195036326640295c02165462abd12b8092b0fa93188f5ee37'
  pushgateway_creates = 'pushgateway-1.11.1.linux-amd64'
when 'aarch64', 'arm64'
  pushgateway_source = 'https://github.com/prometheus/pushgateway/releases/download/v1.11.1/pushgateway-1.11.1.linux-arm64.tar.gz'
  pushgateway_checksum = 'b6dc1c1c46d1137e5eda253f6291247e39330d3065a839857b947e59b4f3e64b'
  pushgateway_creates = 'pushgateway-1.11.1.linux-arm64'
end

default['boxcutter_prometheus']['pushgateway'] = {
  'source' => pushgateway_source,
  'checksum' => pushgateway_checksum,
  'creates' => pushgateway_creates,
}

case node['kernel']['machine']
when 'x86_64', 'amd64'
  blockbox_exporter_source = 'https://github.com/prometheus/blackbox_exporter/releases/download/v0.26.0/blackbox_exporter-0.26.0.linux-amd64.tar.gz'
  blockbox_exporter_checksum = '4b1bb299c685ecff75d41e55e90aae8e02a658395fb14092c7f9c5c9d75016c7'
  blockbox_exporter_creates = 'blackbox_exporter-0.26.0.linux-amd64'
when 'aarch64', 'arm64'
  blockbox_exporter_source = 'https://github.com/prometheus/blackbox_exporter/releases/download/v0.26.0/blackbox_exporter-0.26.0.linux-arm64.tar.gz'
  blockbox_exporter_checksum = 'afb5581b1d4ea45078eebc96e4f989f912d1144d2cc131db8a6c0963bcc6a654'
  blockbox_exporter_creates = 'blackbox_exporter-0.26.0.linux-arm64'
end

default['boxcutter_prometheus']['blackbox_exporter'] = {
  'source' => blockbox_exporter_source,
  'checksum' => blockbox_exporter_checksum,
  'creates' => blockbox_exporter_creates,
  'config' => {},
  'command_line_flags' => {
    'web.listen-address' => ':9115',
  },
}

case node['kernel']['machine']
when 'x86_64', 'amd64'
  node_exporter_source = 'https://github.com/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-amd64.tar.gz'
  node_exporter_checksum = 'becb950ee80daa8ae7331d77966d94a611af79ad0d3307380907e0ec08f5b4e8'
  node_exporter_creates = 'node_exporter-1.9.1.linux-amd64'
when 'aarch64', 'arm64'
  node_exporter_source = 'https://github.com/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-arm64.tar.gz'
  node_exporter_checksum = '848f139986f63232ced83babe3cad1679efdbb26c694737edc1f4fbd27b96203'
  node_exporter_creates = 'node_exporter-1.9.1.linux-arm64'
end

default['boxcutter_prometheus']['node_exporter'] = {
  'source' => node_exporter_source,
  'checksum' => node_exporter_checksum,
  'creates' => node_exporter_creates,
  'command_line_flags' => {
    'collector.systemd' => nil,
    'collector.processes' => nil,
    'no-collector.infiniband' => nil,
    'no-collector.nfs' => nil,
    'collector.textfile' => nil,
    'collector.textfile.directory' => '/var/lib/node_exporter/textfile',
    'web.listen-address' => ':9100',
  },
}

case node['kernel']['machine']
when 'x86_64', 'amd64'
  postgres_exporter_source = 'https://github.com/prometheus-community/postgres_exporter/releases/download/v0.17.1/postgres_exporter-0.17.1.linux-amd64.tar.gz'
  postgres_exporter_checksum = '6da7d2edafd69ecceb08addec876786fa609849f6d5f903987c0d61c3fc89506'
  postgres_exporter_creates = 'postgres_exporter-0.17.1.linux-amd64'
when 'aarch64', 'arm64'
  postgres_exporter_source = 'https://github.com/prometheus-community/postgres_exporter/releases/download/v0.17.1/postgres_exporter-0.17.1.linux-arm64.tar.gz'
  postgres_exporter_checksum = '405af4e838a3d094d575e5aaeac43bd0a1818aaf2c840a3c8fc2c6fcc77218dc'
  postgres_exporter_creates = 'postgres_exporter-0.17.1.linux-arm64'
end

default['boxcutter_prometheus']['postgres_exporter'] = {
  'source' => postgres_exporter_source,
  'checksum' => postgres_exporter_checksum,
  'creates' => postgres_exporter_creates,
  'config' => {},
  'environment' => {},
  'command_line_flags' => {},
}

case node['kernel']['machine']
when 'x86_64', 'amd64'
  redis_exporter_source = 'https://github.com/oliver006/redis_exporter/releases/download/v1.72.0/redis_exporter-v1.72.0.linux-amd64.tar.gz'
  redis_exporter_checksum = '067e10be2e9819da114f0c26e4edb1b8d586adafd9bd23a0f9b736651921def2'
  redis_exporter_creates = 'redis_exporter-v1.72.0.linux-amd64'
when 'aarch64', 'arm64'
  redis_exporter_source = 'https://github.com/oliver006/redis_exporter/releases/download/v1.72.0/redis_exporter-v1.72.0.linux-arm64.tar.gz'
  redis_exporter_checksum = '67ddb8ddbf67ba21a0594388e2a2df9b5db229e932ba1842634cc2ebba2cd0ab'
  redis_exporter_creates = 'redis_exporter-v1.72.0.linux-arm64'
end

default['boxcutter_prometheus']['redis_exporter'] = {
  'source' => redis_exporter_source,
  'checksum' => redis_exporter_checksum,
  'creates' => redis_exporter_creates,
  'command_line_flags' => {},
}

case node['kernel']['machine']
when 'x86_64', 'amd64'
  nvidia_gpu_exporter_source = 'https://github.com/utkuozdemir/nvidia_gpu_exporter/releases/download/v1.3.2/nvidia_gpu_exporter_1.3.2_linux_x86_64.tar.gz'
  nvidia_gpu_exporter_checksum = 'bc10dd41356625d28d18bf4d34c181050fc5c4cf28beee8774846d0140adac5f'
  nvidia_gpu_exporter_creates = 'nvidia_gpu_exporter_1.3.2_linux_x86_64'
when 'aarch64', 'arm64'
  nvidia_gpu_exporter_source = 'https://github.com/utkuozdemir/nvidia_gpu_exporter/releases/download/v1.3.2/nvidia_gpu_exporter_1.3.2_linux_arm64.tar.gz'
  nvidia_gpu_exporter_checksum = 'a201b3eefe08b2b713ccc9d5a929e9353ecd0b94d2ff6001b32dd2549e722ad5'
  nvidia_gpu_exporter_creates = 'nvidia_gpu_exporter_1.3.2_linux_arm64'
end

default['boxcutter_prometheus']['nvidia_gpu_exporter'] = {
  'source' => nvidia_gpu_exporter_source,
  'checksum' => nvidia_gpu_exporter_checksum,
  'creates' => nvidia_gpu_exporter_creates,
  'command_line_flags' => {},
}
