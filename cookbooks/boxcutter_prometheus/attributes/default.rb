case node['kernel']['machine']
when 'x86_64', 'amd64'
  prometheus_source = 'https://github.com/prometheus/prometheus/releases/download/v3.11.0/prometheus-3.11.0.linux-amd64.tar.gz'
  prometheus_checksum = 'ff799c3e4c318e17dec14aaaa406a4da328fabb4578336b36d96d893870c3b76'
  prometheus_creates = 'prometheus-3.11.0.linux-amd64'
when 'aarch64', 'arm64'
  prometheus_source = 'https://github.com/prometheus/prometheus/releases/download/v3.11.0/prometheus-3.11.0.linux-arm64.tar.gz'
  prometheus_checksum = '4d983175e77161e30b94922c49fdb681cf849439613d24a026bbb8d1ca4e8728'
  prometheus_creates = 'prometheus-3.11.0.linux-arm64'
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
  alertmanager_source = 'https://github.com/prometheus/alertmanager/releases/download/v0.31.1/alertmanager-0.31.1.linux-amd64.tar.gz'
  alertmanager_checksum = '35191cbd9d4f8162458b78dd7e93990cccd246044d9a6f788adb1c66ac3ea07b'
  alertmanager_creates = 'alertmanager-0.31.1.linux-amd64'
when 'aarch64', 'arm64'
  alertmanager_source = 'hhttps://github.com/prometheus/alertmanager/releases/download/v0.31.1/alertmanager-0.31.1.linux-arm64.tar.gz'
  alertmanager_checksum = '266dda88b64318c27847ef9af4ff450fc178c827550a8039420c5ca8657a4a8b'
  alertmanager_creates = 'alertmanager-0.31.1.linux-arm64'
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
  blockbox_exporter_checksum = 'caf5d242fb1cf6d5cb678f3f799f22703d4fafea26b03dcbbd7e1f1825e06329'
  blockbox_exporter_creates = 'blackbox_exporter-0.28.0.linux-amd64'
when 'aarch64', 'arm64'
  blockbox_exporter_source = 'https://github.com/prometheus/blackbox_exporter/releases/download/v0.28.0/blackbox_exporter-0.28.0.linux-arm64.tar.gz'
  blockbox_exporter_checksum = '63312be0983d85e5109710a7dc93df3051157ae581853fa3655d171cc1b2806e'
  blockbox_exporter_creates = 'blackbox_exporter-0.28.0.linux-arm64'
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
  node_exporter_source = 'https://github.com/prometheus/node_exporter/releases/download/v1.11.0/node_exporter-1.11.0.linux-amd64.tar.gz'
  node_exporter_checksum = '4f8fbd23b8380b8fb720b125fb9029de261dc5fcd68bfe81ae010c0d32f5f6c3'
  node_exporter_creates = 'node_exporter-1.11.0.linux-amd64'
when 'aarch64', 'arm64'
  node_exporter_source = 'https://github.com/prometheus/node_exporter/releases/download/v1.11.0/node_exporter-1.11.0.linux-arm64.tar.gz'
  node_exporter_checksum = 'cd09ceffd418e91c25365ad008b2baac88fa1743632b71c620829d3d5596b141'
  node_exporter_creates = 'node_exporter-1.11.0.linux-arm64'
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
  postgres_exporter_source = 'https://github.com/prometheus-community/postgres_exporter/releases/download/v0.19.1/postgres_exporter-0.19.1.linux-amd64.tar.gz'
  postgres_exporter_checksum = '229096c7988df6ca41fe5b4bf66865089971535e7f0d819c12c920ec64dd2bd0'
  postgres_exporter_creates = 'postgres_exporter-0.19.1.linux-amd64'
when 'aarch64', 'arm64'
  postgres_exporter_source = 'https://github.com/prometheus-community/postgres_exporter/releases/download/v0.19.1/postgres_exporter-0.19.1.linux-arm64.tar.gz'
  postgres_exporter_checksum = '0ac6fe8c1f66f13b12adb8da282d248d9e1a48df6684e453ca232fd8fd62a11a'
  postgres_exporter_creates = 'postgres_exporter-0.19.1.linux-arm64'
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
  redis_exporter_checksum = 'a807907d413edb1c0aa88513e7c1570c302873bd1cfcbf36fb53a14629177882'
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
  nvidia_gpu_exporter_source = 'https://github.com/utkuozdemir/nvidia_gpu_exporter/releases/download/v1.4.1/nvidia_gpu_exporter_1.4.1_linux_x86_64.tar.gz'
  nvidia_gpu_exporter_checksum = '0c7dd64b424ff54c7860777faa4da703e5a7486ea258cf6d6f5620fc691feaa5'
  nvidia_gpu_exporter_creates = 'nvidia_gpu_exporter_1.4.1_linux_x86_64'
when 'aarch64', 'arm64'
  nvidia_gpu_exporter_source = 'https://github.com/utkuozdemir/nvidia_gpu_exporter/releases/download/v1.4.1/nvidia_gpu_exporter_1.4.1_linux_arm64.tar.gz'
  nvidia_gpu_exporter_checksum = '0256d69167582eaf44c1412859fb267a562ca0eb56ce3d6d76781533589fee3b'
  nvidia_gpu_exporter_creates = 'nvidia_gpu_exporter_1.4.1_linux_arm64'
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
