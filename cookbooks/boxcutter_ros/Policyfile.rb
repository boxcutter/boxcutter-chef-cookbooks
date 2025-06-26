# Policyfile.rb - Describe how you want Chef Infra Client to build your system.
#
# For more information on the Policyfile feature, visit
# https://docs.chef.io/policyfile/

# A name that describes what the system you're building with Chef does.
name 'boxcutter_ros'

# Where to find external cookbooks:
default_source :chef_repo, '../../../chef-cookbooks/cookbooks'
default_source :chef_repo, '../'

# run_list: chef-client will run these recipes in the order specified.
run_list 'boxcutter_ohai', 'boxcutter_init', 'boxcutter_ros_test::default'
named_run_list 'boxcutter_ros_test_build_essential',
               'boxcutter_ohai', 'boxcutter_init', 'boxcutter_ros_test::build_essential'
named_run_list 'boxcutter_ros_test_dev_tools',
               'boxcutter_ohai', 'boxcutter_init', 'boxcutter_ros_test::dev_tools'
named_run_list 'boxcutter_ros_test_rocker',
               'boxcutter_ohai', 'boxcutter_init', 'boxcutter_ros_test::rocker'

# Specify a custom source for a single cookbook:
cookbook 'boxcutter_ros', path: '.'
cookbook 'boxcutter_ros_test', path: 'test/cookbooks/boxcutter_ros_test'
