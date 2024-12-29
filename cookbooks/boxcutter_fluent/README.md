# boxcutter_fluent

Configures Fluentd and Fluent Bit log forwarding and aggregation. Both are
part of the Fluent suite of tools.

Unless you have a specific reason because of a legacy app or missing plugin,
you should prefer using Fluent Bit over Fluentd, Fluent Bit is written in C
and has a smaller footprint than Fluentd, and it supports the open telemetry
standard. However, Fluentd provides some extra tooling and scripts that can
be useful in Fluent Bit, so this cookbook supports installing both tools.

Fluent Bit and Fluentd can be installed side-by-side on the same machine
without interfering with each other. Each tools uses a completely different
set of config files and binaries that do not overlap.

If you want to learn more about how to use Fluentd and Fluent Bit, the
following Manning books are helpful. The "Logs and Telemetry" book is older,
and covers both Fluentd and Fluent Bit. "Logs and Telemetry" was published
more recently and covers Fluent Bit exclusively.

- "Logging in Action", by Phil Wilkins, 2022
- "Logs and Telemetry", by Phil Wilkins, 2024

## Configuring Fluentd

Include `boxcutter_fluent::fluent_package` to get a default Fluentd server.

This automation reconfigures Fluentd to use YAML configuration files instead
of the legacy `.conf` file format as this is now the recommended config
format. It's also easier to write config file generators in Chef.

The configuration for Fluentd is driven by the
`node['boxcutter_fluent']['fluentd']['config']` attribute. It contains a
hash that maps directly to the contents of the `/etc/fluent/fluentd.yaml`
config file.

```yaml
node.default['boxcutter_fluent']['fluentd']['config'] = {
  'system' => {
    'log_level' => 'info',
  },
  'config' => [
    {
      'source' => {
        '$type' => 'http',
        'port' => '18080',
      },
    },
    {
      'match' => {
        '$tag' => '*',
        '$type' => 'stdout',
      },
    },
  ],
}
```

## Configuring Fluent Bit

Include `boxcutter_fluent::fluent_bit` to get a default Fluent Bit server.

This automation reconfigures Fluent Bit to use YAML configuration files instead
of the legacy `.conf` file format as this is now the recommended config
format. It's also easier to write config file generators in Chef.

The configuration for Fluent Bit is driven by the
`node['boxcutter_fluent']['fluent_bit']['config']` attribute. It contains a
hash that maps directly to the contents of the `/etc/fluent-bit/fluent-bit.yaml`
config file.

```yaml
node.default['boxcutter_fluent']['fluent_bit']['config'] = {
  'service' => {
    'log_level' => 'info',
  },
  'pipeline' => {
    'inputs' => [
      {
        'name' => 'http',
        'listen' => '0.0.0.0',
        'port' => '8888',
      }
    ],
    'outputs' => [
      {
        'name' => 'stdout',
        'match' => '*',
      }
    ]
  }
}
```
