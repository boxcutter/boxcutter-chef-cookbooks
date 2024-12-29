#
# Cookbook:: boxcutter_fluent_test
# Recipe:: default
#

# node.default['boxcutter_fluent']['fluentd'] = {
#   'enable' => false,
#   'config' => {
#     'system' => {
#       'log_level' => 'info',
#     },
#     'config' => [
#       {
#         'source' => {
#           '$type' => 'http',
#           'port' => '18080',
#         },
#       },
#       {
#         'match' => {
#           '$tag' => '*',
#           '$type' => 'stdout',
#         },
#       }
#     ]
#   }
# }

# node.default['boxcutter_fluent']['fluentd'] = {
#   'enable' => false,
#   'config' => {
#     'system' => {
#       'log_level' => 'info',
#     },
#     'config' => [
#       {
#         'source' => {
#           '$type' => 'http',
#           'port' => '18080',
#         },
#       },
#       {
#         'source' => {
#           '$type' => 'dummy',
#           'dummy' => '{"dummy says": "hello"}',
#           'rate' => '1',
#           'auto_increment_key' => 'counter',
#           'tag' => 'dummySource',
#         }
#       },
#       {
#         'match' => {
#           '$tag' => '*',
#           '$type' => 'stdout',
#         },
#       }
#     ]
#   }
# }

# /opt/fluent/bin/fluentd --dry-run -c /etc/fluent/fluentd.yaml
# /opt/fluent/bin/fluentd -c /etc/fluent/fluentd.yaml

include_recipe 'boxcutter_fluent::fluent_package'

# # chapter2/fluentbit/hello-world.yaml
# node.default['boxcutter_fluent']['fluent_bit'] = {
#   'enable' => false,
#   'config' => {
#     'env' => {
#       'flush_interval' => 2,
#     },
#     'service' => {
#       'flush' => '${flush_interval}',
#       'log_level' => 'info',
#     },
#     'pipeline' => {
#       'inputs' => [
#         {
#           'name' => 'dummy',
#           'dummy' => '{ "hello": "world" }',
#           'tag' => 'dummy1',
#         }
#       ],
#       'outputs' => [
#         {
#           'name' => 'stdout',
#           'match' => '*',
#         }
#       ]
#     }
#   },
# }

# # chapter2/fluentbit/hello-world-2.yaml
# node.default['boxcutter_fluent']['fluent_bit'] = {
#   'enable' => false,
#   'config' => {
#     'env' => {
#       'flush_interval' => 1,
#     },
#     'service' => {
#       'flush' => '${flush_interval}',
#       'log_level' => 'info',
#     },
#     'pipeline' => {
#       'inputs' => [
#         {
#           'name' => 'dummy',
#           'dummy' => '{ "hello": "world" }',
#           'tag' => 'dummy1',
#         },
#         {
#           'name' => 'dummy',
#           'dummy' => '{ "more": "stuff" }',
#           'tag' => 'dummy2',
#         },
#       ],
#       'outputs' => [
#         {
#           'name' => 'stdout',
#           'match' => '*',
#         },
#         {
#           'name' => 'stdout',
#           'match' => '*',
#           'format' => 'json',
#           'json_date_format' => 'iso8601',
#         }
#       ]
#     }
#   },
# }

# # chapter2/fluentbit/hello-world.error.yaml
# node.default['boxcutter_fluent']['fluent_bit'] = {
#   'enable' => false,
#   'config' => {
#     'env' => {
#       'flush_interval' => 1,
#     },
#     'service' => {
#       'flush' => '${flush_interval}',
#       'log_level' => 'info',
#     },
#     'pipeline' => {
#       'inputs' => [
#         {
#           'name' => 'dumm',
#           'dummy' => '{ "hello": "world" }',
#           'tag' => 'dummy1',
#         },
#       ],
#       'outputs' => [
#         {
#           'name' => 'stdt',
#           'match' => '*',
#         },
#       ]
#     }
#   },
# }

# /opt/fluent-bit/bin/fluent-bit --dry-run -c /etc/fluent-bit/fluent-bit.yaml
# /opt/fluent-bit/bin/fluent-bit -c /etc/fluent-bit/fluent-bit.yaml

include_recipe 'boxcutter_fluent::fluent_bit'
