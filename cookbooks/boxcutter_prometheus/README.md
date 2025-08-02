boxcutter_prometheus
====================

Usage
-----

### Prometheus

The `boxcutter_prometheus::prometheus` recipe will install and configure
the prometheus time series database.

```bash
node.default['boxcutter_prometheus']['prometheus']['config'] = {
  'global' => {
    'scrape_interval' => '60s',
  },
  'scrape_configs' => [{
    'job_name' => 'prometheus',
    'static_configs' => [{
      'targets' => ['localhost:9090'],
    }],
  }],
}
```

You can use a little syntactic sugar in order to specify the arrays of
hashes used in prometheus configuration. If you use the hash key of
`index_*`, it will be convert the entries to an array of hashes:

```bash
node.default['boxcutter_prometheus']['prometheus']['config'] = {
  'global' => {
    'scrape_interval' => '60s',
  },
  'scrape_configs' => {
    'index_1' => {
      'job_name' => 'prometheus',
      'static_configs' => {
        'index_1' => {
          'targets' => ['localhost:9090'],
        },
      },
    },
    'index_2' => {
      'job_name' => 'node',
      'static_configs' => {
        'index_2' => {
          'targets' => ['localhost:9090'],
        },
      },
    },
  },
}
````

Use the `source`, `checksum` and `creates` attributes to choose to install
a different version of node exporter than the default. Normally you'll also
need to specify these by architecture as well. These attributes correspond to
similar attributes in the `remote_file` resource and serve a similar purpose.
The `creates` attribute specifies the sub-directory name for the extracted files.

```bash
case node['kernel']['machine']
when 'x86_64', 'amd64'
  node.default['boxcutter_prometheus']['prometheus']['source'] = \
    'https://github.com/prometheus/prometheus/releases/download/v3.4.1/prometheus-3.4.1.linux-amd64.tar.gz'
  node.default['boxcutter_prometheus']['prometheus']['checksum'] = \
    '09203151c132f36b004615de1a3dea22117ad17e6d7a59962e34f3abf328f312'
  node.default['boxcutter_prometheus']['prometheus']['creates'] = \
    'prometheus-3.4.1.linux-amd64'
when 'aarch64', 'arm64'
  node.default['boxcutter_prometheus']['prometheus']['source'] = \
    'https://github.com/prometheus/prometheus/releases/download/v3.4.1/prometheus-3.4.1.linux-arm64.tar.gz'
  node.default['boxcutter_prometheus']['prometheus']['checksum'] = \
    '2a85be1dff46238c0d799674e856c8629c8526168dd26c3de2cecfbfc6f9a0a2'
  node.default['boxcutter_prometheus']['prometheus']['creates'] = \
    'prometheus-3.4.1.linux-arm64'
end
```

You can choose whether or not to enable the prometheus service with the
`node['boxcutter_prometheus']['prometheus']['enable']` attribute. The
default value is `false`.

### Node exporter

The `boxcutter_prometheus::node_exporter` recipe will install and configure
node exporter.

You can choose whether or not to enable the node exporter service with the
`node['boxcutter_prometheus']['node_exporter']['enable']` attribute. The
default value is `false`.

All of the configuration for node exporter is done via
`node['boxcutter_prometheus']['node_exporter']['command_line_flags']`. Refer
to the node exporter [README.md](https://github.com/prometheus/node_exporter)
for more information on the meaning of the various flags. If a flag has no
value, use `nil`.

If you use the textfile collector, we expect the directory to be
`/var/lib/node_exporter/textfile` by default.

```bash
node.default['boxcutter_prometheus']['node_exporter']['command_line_flags'] = {
  'collector.systemd' => nil,
  'collector.processes' => nil,
  'no-collector.infiniband' => nil,
  'no-collector.nfs' => nil,
  'collector.textfile' => nil,
  'collector.textfile.directory' => '/var/lib/node_exporter/textfile',
  'web.listen-address' => 'localhost:9100',
}
````

Use the `source`, `checksum` and `creates` attributes to choose to install
a different version of node exporter than the default. Normally you'll also
need to specify these by architecture as well. These attributes correspond to
similar attributes in the `remote_file` resource and serve a similar purpose.
The `creates` attribute specifies the sub-directory name for the extracted files.

```bash
 case node['kernel']['machine']
 when 'x86_64', 'amd64'
   node.default['boxcutter_prometheus']['node_exporter']['source'] = \
     'https://github.com/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-amd64.tar.gz'
   node.default['boxcutter_prometheus']['node_exporter']['checksum'] = \
     'becb950ee80daa8ae7331d77966d94a611af79ad0d3307380907e0ec08f5b4e8'
   node.default['boxcutter_prometheus']['node_exporter']['creates'] = \
     'node_exporter-1.9.1.linux-amd64'
 when 'aarch64', 'arm64'
   node.default['boxcutterprometheus']['node_exporter']['source'] = \
     'https://github.com/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-arm64.tar.gz'
   node.default['boxcutter_prometheus']['node_exporter']['checksum'] = \
     '848f139986f63232ced83babe3cad1679efdbb26c694737edc1f4fbd27b96203'
   node.default['boxcutter_prometheus']['node_exporter']['creates'] = \
     'node_exporter-1.9.1.linux-arm64'
 end
```

You can choose whether or not to enable the node exporter service with the
`node['boxcutter_prometheus']['node_exporter']['enable']` attribute. The
default value is `false`.

### SNMP exporter

The `boxcutter_prometheus::snmp_exporter` recipe will install and configure
SNMP exporter.

By default the `snmp.yml` used is the generated one that ships with the snmp
exporter release. For configuration, we allow you to customize the auth

```bash
# SNMP v1
node.default['boxcutter_prometheus']['snmp_exporter']['auth'] = {
  'version' => '1',
  'community' => 'public'  
}

# SNMP v2c
node.default['boxcutter_prometheus']['snmp_exporter']['auth'] = {
  'version' => '2',
  'community' => 'public'  
}

# SNMP v3
node.default['boxcutter_prometheus']['snmp_exporter']['auth'] = {
  'version' => '3',
  'security_level' => 'authPriv',
  'username' => 'snmpreader',
  'auth_protocol' => 'SHA',
  'password' => 'superseekret',
  'priv_protocol' => 'AES',
  'priv_password' => 'superseekret'  
}
```

Since the 'community', 'password' and 'priv_password' attributes are secrets,
it is recommended that you store these fields in `node.run_state` so that it
is not stored on the Chef server after the Chef run in plaintext.

```bash
# SNMP v1 - community string
## Initialize the parent hash if it doesn't exist
node.run_state['boxcutter_prometheus'] ||= {}
node.run_state['boxcutter_prometheus']['snmp_exporter'] ||= {}
node.run_state['boxcutter_prometheus']['snmp_exporter']['auth'] ||= {}
node.run_state['boxcutter_prometheus']['snmp_exporter']['auth']['community'] \
  = 'superseekret'

# SNMP v2 - community string
## Initialize the parent hash if it doesn't exist
node.run_state['boxcutter_prometheus'] ||= {}
node.run_state['boxcutter_prometheus']['snmp_exporter'] ||= {}
node.run_state['boxcutter_prometheus']['snmp_exporter']['auth'] ||= {}
node.run_state['boxcutter_prometheus']['snmp_exporter']['auth']['community'] \
  = 'superseekret'

# SNMP v3 - password and priv_password
## Initialize the parent hash if it doesn't exist
node.run_state['boxcutter_prometheus'] ||= {}
node.run_state['boxcutter_prometheus']['snmp_exporter'] ||= {}
node.run_state['boxcutter_prometheus']['snmp_exporter']['auth'] ||= {}
node.run_state['boxcutter_prometheus']['snmp_exporter']['auth']['password'] \
  = 'superseekret'
node.run_state['boxcutter_prometheus']['snmp_exporter']['auth']['priv_password'] \
  = 'superseekret'
```

The rest the configuration for snmp exporter is done via
`node['boxcutter_prometheus']['snmp_exporter']['command_line_flags']`. Refer
to the SNMP exporter [README.md](https://github.com/prometheus/snmp_exporter)
for more information on the meaning of the various flags. If a flag has no
value, use `nil`.

```bash
node.default['boxcutter_prometheus']['snmp_exporter']['command_line_flags'] = {
  'web.listen-address' => ':9116',
}
```

You can choose whether or not to enable the SNMP exporter service with the
`node['boxcutter_prometheus']['SNMP_exporter']['enable']` attribute. The
default value is `true`.

Use the `source`, `checksum` and `creates` attributes to choose to install
a different version of node exporter than the default. Normally you'll also
need to specify these by architecture as well. These attributes correspond to
similar attributes in the `remote_file` resource and serve a similar purpose.
The `creates` attribute specifies the sub-directory name for the extracted files.

```bash
 case node['kernel']['machine']
 when 'x86_64', 'amd64'
   node.default['boxcutter_prometheus']['snmp_exporter']['source'] = \
     'https://github.com/prometheus/snmp_exporter/releases/download/v0.29.0/snmp_exporter-0.29.0.linux-amd64.tar.gz'
   node.default['boxcutter_prometheus']['snmp_exporter']['checksum'] = \
     'fd7ded886180063a8f77e1ca18cc648e44b318b9c92bcb3867b817d93a5232d6'
   node.default['boxcutter_prometheus']['snmp_exporter']['creates'] = \
     'snmp_exporter-0.29.0.linux-amd64.'
 when 'aarch64', 'arm64'
   node.default['boxcutterprometheus']['node_exporter']['source'] = \
     'https://github.com/prometheus/snmp_exporter/releases/download/v0.29.0/snmp_exporter-0.29.0.linux-arm64.tar.gz'
   node.default['boxcutter_prometheus']['node_exporter']['checksum'] = \
     'e590870ad2fcd39ea9c7d722d6e85aa6f1cc9e8671ff3f17feba12a6b5a3b47a'
   node.default['boxcutter_prometheus']['node_exporter']['creates'] = \
     'snmp_exporter-0.29.0.linux-arm64'
 end
```
