# Policyfile.rb - Describe how you want Chef Infra Client to build your system.
#
# For more information on the Policyfile feature, visit
# https://docs.chef.io/policyfile/

# A name that describes what the system you're building with Chef does.
name 'boxcutter_onepassword'

# Where to find external cookbooks:
default_source :chef_repo, '../../../chef-cookbooks/cookbooks'
default_source :chef_repo, '../'

# run_list: chef-client will run these recipes in the order specified.
run_list 'boxcutter_ohai', 'boxcutter_init', 'boxcutter_onepassword_test::cli'
named_run_list 'boxcutter_onepassword_test_cli', 'boxcutter_ohai', 'boxcutter_init', 'boxcutter_onepassword_test::cli'
named_run_list 'boxcutter_onepassword_test_service_account', 'boxcutter_ohai', 'boxcutter_init',
               'boxcutter_onepassword_test::service_account'
named_run_list 'boxcutter_onepassword_test_connect_server', 'boxcutter_ohai', 'boxcutter_init',
               'boxcutter_onepassword_test::connect_server'

# Specify a custom source for a single cookbook:
cookbook 'boxcutter_onepassword', path: '.'
cookbook 'boxcutter_onepassword_test', path: 'test/cookbooks/boxcutter_onepassword_test'
