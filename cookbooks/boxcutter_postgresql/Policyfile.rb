# Policyfile.rb - Describe how you want Chef Infra Client to build your system.
#
# For more information on the Policyfile feature, visit
# https://docs.chef.io/policyfile/

# A name that describes what the system you're building with Chef does.
name 'boxcutter_postgresql'

# Where to find external cookbooks:
default_source :chef_repo, '../../../chef-cookbooks/cookbooks'
default_source :chef_repo, '../'

# run_list: chef-client will run these recipes in the order specified.
run_list 'boxcutter_ohai', 'boxcutter_init', 'boxcutter_postgresql::default'
named_run_list 'boxcutter_postgresql_test_client', 'boxcutter_ohai', 'boxcutter_init',
               'boxcutter_postgresql_test::client'
named_run_list 'boxcutter_postgresql_test_server', 'boxcutter_ohai', 'boxcutter_init',
               'boxcutter_postgresql_test::server'

# Specify a custom source for a single cookbook:
cookbook 'boxcutter_postgresql', path: '.'
cookbook 'boxcutter_postgresql_test', path: 'test/cookbooks/boxcutter_postgresql_test'
