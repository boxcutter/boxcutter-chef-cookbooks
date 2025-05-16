# Policyfile.rb - Describe how you want Chef Infra Client to build your system.
#
# For more information on the Policyfile feature, visit
# https://docs.chef.io/policyfile/

# A name that describes what the system you're building with Chef does.
name 'boxcutter_prometheus'

# Where to find external cookbooks:
default_source :chef_repo, '../../../chef-cookbooks/cookbooks'
default_source :chef_repo, '../'

# run_list: chef-client will run these recipes in the order specified.
run_list 'boxcutter_ohai', 'boxcutter_init', 'boxcutter_prometheus_test::default'
named_run_list 'boxcutter_prometheus_test_prometheus',
               'boxcutter_ohai', 'boxcutter_init', 'boxcutter_prometheus_test::prometheus'
named_run_list 'boxcutter_prometheus_test_alertmanager',
               'boxcutter_ohai', 'boxcutter_init', 'boxcutter_prometheus_test::alertmanager'
named_run_list 'boxcutter_prometheus_test_pushgateway',
               'boxcutter_ohai', 'boxcutter_init', 'boxcutter_prometheus_test::pushgateway'
named_run_list 'boxcutter_prometheus_test_blackbox_exporter',
               'boxcutter_ohai', 'boxcutter_init', 'boxcutter_prometheus_test::blackbox_exporter'
named_run_list 'boxcutter_prometheus_test_node_exporter',
               'boxcutter_ohai', 'boxcutter_init', 'boxcutter_prometheus_test::node_exporter'
named_run_list 'boxcutter_prometheus_test_postgres_exporter',
               'boxcutter_ohai', 'boxcutter_init', 'boxcutter_prometheus_test::postgres_exporter'
named_run_list 'boxcutter_prometheus_test_redis_exporter',
               'boxcutter_ohai', 'boxcutter_init', 'boxcutter_prometheus_test::redis_exporter'
named_run_list 'boxcutter_prometheus_test_nvidia_gpu_exporter',
               'boxcutter_ohai', 'boxcutter_init', 'boxcutter_prometheus_test::nvidia_gpu_exporter'

# Specify a custom source for a single cookbook:
cookbook 'boxcutter_prometheus', path: '.'
cookbook 'boxcutter_prometheus_test', path: 'test/cookbooks/boxcutter_prometheus_test'
