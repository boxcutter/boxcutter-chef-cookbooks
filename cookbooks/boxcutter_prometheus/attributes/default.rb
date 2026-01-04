case node['kernel']['machine']
when 'x86_64', 'amd64'
  prometheus_source = 'https://github.com/prometheus/prometheus/releases/download/v3.8.1/prometheus-3.8.1.linux-amd64.tar.gz'
  prometheus_checksum = 'a09972ced892cd298e353eb9559f1a90f499da3fb4ff0845be352fc138780ee7'
  prometheus_creates = 'prometheus-3.8.1.linux-amd64'
when 'aarch64', 'arm64'
  prometheus_source = 'https://github.com/prometheus/prometheus/releases/download/v3.8.1/prometheus-3.8.1.linux-arm64.tar.gz'
  prometheus_checksum = '8d95804e692bba65a48d32ecdfb3d4acd8e1560d440c8cc08f48167cb838ec4b'
  prometheus_creates = 'prometheus-3.8.1.linux-arm64'
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
    'web.listen-address' => 'localhost:9090',
  },
}

case node['kernel']['machine']
when 'x86_64', 'amd64'
  alertmanager_source = 'https://github.com/prometheus/alertmanager/releases/download/v0.30.0/alertmanager-0.30.0.linux-amd64.tar.gz'
  alertmanager_checksum = '86fd95034e3e17094d6951118c54b396200be22a1c16af787e1f7129ebce8f1f'
  alertmanager_creates = 'alertmanager-0.30.0.linux-amd64'
when 'aarch64', 'arm64'
  alertmanager_source = 'https://github.com/prometheus/alertmanager/releases/download/v0.30.0/alertmanager-0.30.0.linux-arm64.tar.gz'
  alertmanager_checksum = '061a5ab3998fb8af75192980a559c7bfa3892da55098da839d7a79d94abe0b61'
  alertmanager_creates = 'alertmanager-0.30.0.linux-arm64'
end

default['boxcutter_prometheus']['alertmanager'] = {
  'enable' => true,
  'source' => alertmanager_source,
  'checksum' => alertmanager_checksum,
  'creates' => alertmanager_creates,
  'config' => {
    'route' => {
      'receiver' => 'null',
    },
    'receivers' => [
      {
        'name' => 'null',
      },
    ],
  },
  'command_line_flags' => {
    'storage.path' => '/var/lib/alertmanager/data',
    'web.listen-address' => 'localhost:9093',
  },
}

case node['kernel']['machine']
when 'x86_64', 'amd64'
  pushgateway_source = 'https://github.com/prometheus/pushgateway/releases/download/v1.11.2/pushgateway-1.11.2.linux-amd64.tar.gz'
  pushgateway_checksum = '2ec72315e150dda071fdeef09360780a386a67e5207ebaa53bb18f2f1a3b89cf'
  pushgateway_creates = 'pushgateway-1.11.2.linux-amd64'
when 'aarch64', 'arm64'
  pushgateway_source = 'https://github.com/prometheus/pushgateway/releases/download/v1.11.2/pushgateway-1.11.2.linux-arm64.tar.gz'
  pushgateway_checksum = 'b3fb835dbb0a29b1d6f9cd7ae3568a5615e59b96f8787965248cea67163d4db1'
  pushgateway_creates = 'pushgateway-1.11.2.linux-arm64'
end

default['boxcutter_prometheus']['pushgateway'] = {
  'enable' => true,
  'source' => pushgateway_source,
  'checksum' => pushgateway_checksum,
  'creates' => pushgateway_creates,
  'command_line_flags' => {
    'web.listen-address' => 'localhost:9115',
  },
}

case node['kernel']['machine']
when 'x86_64', 'amd64'
  blockbox_exporter_source = 'https://github.com/prometheus/blackbox_exporter/releases/download/v0.28.0/blackbox_exporter-0.28.0.linux-amd64.tar.gz'
  blockbox_exporter_checksum = '4b1bb299c685ecff75d41e55e90aae8e02a658395fb14092c7f9c5c9d75016c7'
  blockbox_exporter_creates = 'blackbox_exporter-0.26.0.linux-amd64'
when 'aarch64', 'arm64'
  blockbox_exporter_source = 'https://github.com/prometheus/blackbox_exporter/releases/download/v0.26.0/blackbox_exporter-0.26.0.linux-arm64.tar.gz'
  blockbox_exporter_checksum = 'afb5581b1d4ea45078eebc96e4f989f912d1144d2cc131db8a6c0963bcc6a654'
  blockbox_exporter_creates = 'blackbox_exporter-0.26.0.linux-arm64'
end

default['boxcutter_prometheus']['blackbox_exporter'] = {
  'enable' => true,
  'source' => blockbox_exporter_source,
  'checksum' => blockbox_exporter_checksum,
  'creates' => blockbox_exporter_creates,
  'config' => {},
  'command_line_flags' => {
    'web.listen-address' => 'localhost:9115',
  },
}

case node['kernel']['machine']
when 'x86_64', 'amd64'
  node_exporter_source = 'https://github.com/prometheus/node_exporter/releases/download/v1.10.2/node_exporter-1.10.2.linux-amd64.tar.gz'
  node_exporter_checksum = 'c46e5b6f53948477ff3a19d97c58307394a29fe64a01905646f026ddc32cb65b'
  node_exporter_creates = 'node_exporter-1.10.2.linux-amd64'
when 'aarch64', 'arm64'
  node_exporter_source = 'https://github.com/prometheus/node_exporter/releases/download/v1.10.2/node_exporter-1.10.2.linux-arm64.tar.gz'
  node_exporter_checksum = 'de69ec8341c8068b7c8e4cfe3eb85065d24d984a3b33007f575d307d13eb89a6'
  node_exporter_creates = 'node_exporter-1.10.2.linux-arm64'
end

default['boxcutter_prometheus']['node_exporter'] = {
  'enable' => true,
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
    'web.listen-address' => 'localhost:9100',
  },
}

case node['kernel']['machine']
when 'x86_64', 'amd64'
  postgres_exporter_source = 'https://github.com/prometheus-community/postgres_exporter/releases/download/v0.18.1/postgres_exporter-0.18.1.linux-amd64.tar.gz'
  postgres_exporter_checksum = '1630965540d49a4907ad181cef5696306d7a481f87f43978538997e85d357272'
  postgres_exporter_creates = 'postgres_exporter-0.18.1.linux-amd64'
when 'aarch64', 'arm64'
  postgres_exporter_source = 'https://github.com/prometheus-community/postgres_exporter/releases/download/v0.18.1/postgres_exporter-0.18.1.linux-arm64.tar.gz'
  postgres_exporter_checksum = '81c22dc2b6dcc58e9e2b5c0e557301dbf0ca0812ee3113d31984c1a37811d1cc'
  postgres_exporter_creates = 'postgres_exporter-0.18.1.linux-arm64'
end

default['boxcutter_prometheus']['postgres_exporter'] = {
  'enable' => true,
  'source' => postgres_exporter_source,
  'checksum' => postgres_exporter_checksum,
  'creates' => postgres_exporter_creates,
  'config' => {},
  'environment' => {},
  'command_line_flags' => {
    'web.listen-address' => 'localhost:9187',
  },
}

case node['kernel']['machine']
when 'x86_64', 'amd64'
  redis_exporter_source = 'https://github.com/oliver006/redis_exporter/releases/download/v1.80.1/redis_exporter-v1.80.1.linux-amd64.tar.gz'
  redis_exporter_checksum = '1818cc2cbd3bac62a6f43054a2cc1596fc5f6148ce80112a6308bc3cad6d81fa'
  redis_exporter_creates = 'redis_exporter-v1.80.1.linux-amd64'
when 'aarch64', 'arm64'
  redis_exporter_source = 'https://github.com/oliver006/redis_exporter/releases/download/v1.80.1/redis_exporter-v1.80.1.linux-arm64.tar.gz'
  redis_exporter_checksum = 'sha256:a807907d413edb1c0aa88513e7c1570c302873bd1cfcbf36fb53a14629177882'
  redis_exporter_creates = 'redis_exporter-v1.80.1.linux-arm64'
end

default['boxcutter_prometheus']['redis_exporter'] = {
  'enable' => true,
  'source' => redis_exporter_source,
  'checksum' => redis_exporter_checksum,
  'creates' => redis_exporter_creates,
  'command_line_flags' => {
    'web.listen-address' => 'localhost:9121',
  },
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
  'enable' => true,
  'source' => nvidia_gpu_exporter_source,
  'checksum' => nvidia_gpu_exporter_checksum,
  'creates' => nvidia_gpu_exporter_creates,
  'command_line_flags' => {
    'web.listen-address' => 'localhost:9835',
  },
}

case node['kernel']['machine']
when 'x86_64', 'amd64'
  snmp_exporter_source = 'https://github.com/prometheus/snmp_exporter/releases/download/v0.29.0/snmp_exporter-0.29.0.linux-amd64.tar.gz'
  snmp_exporter_checksum = 'fd7ded886180063a8f77e1ca18cc648e44b318b9c92bcb3867b817d93a5232d6'
  snmp_exporter_creates = 'snmp_exporter-0.29.0.linux-amd64'
when 'aarch64', 'arm64'
  snmp_exporter_source = 'https://github.com/prometheus/snmp_exporter/releases/download/v0.29.0/snmp_exporter-0.29.0.linux-arm64.tar.gz'
  snmp_exporter_checksum = 'e590870ad2fcd39ea9c7d722d6e85aa6f1cc9e8671ff3f17feba12a6b5a3b47a'
  snmp_exporter_creates = 'snmp_exporter-0.29.0.linux-arm64'
end

default['boxcutter_prometheus']['snmp_exporter'] = {
  'enable' => true,
  'source' => snmp_exporter_source,
  'checksum' => snmp_exporter_checksum,
  'creates' => snmp_exporter_creates,
  'auth' => {
    'version' => '3',
    'community' => 'public',
    'security_level' => nil,
    'username' => nil,
    'auth_protocol' => 'MD5',
    'password' => nil,
    'priv_protocol' => 'DES',
    'priv_password' => nil,
    'context_name' => nil,
  },
  'command_line_flags' => {
    'web.listen-address' => 'localhost:9116',
  },
}
