# boxcutter_prometheus

## Usage

### Prometheus

The `boxcutter_prometheus::prometheus` recipe will install and configure
the prometheus time series database.

```bash
node.default['boxcutter_prometheus']['prometheus']['config'] = {
  'global' => {
    'scrape_interval' => '10s',
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
    'scrape_interval' => '10s',
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
