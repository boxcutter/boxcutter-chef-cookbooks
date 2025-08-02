# Policyfile.rb - Describe how you want Chef Infra Client to build your system.
#
# For more information on the Policyfile feature, visit
# https://docs.chef.io/policyfile/

# A name that describes what the system you're building with Chef does.
name 'boxcutter_users'

# Where to find external cookbooks:
default_source :chef_repo, '../../../chef-cookbooks/cookbooks'
default_source :chef_repo, '../'

# run_list: chef-client will run these recipes in the order specified.
run_list 'boxcutter_init', 'boxcutter_users::default'

# Specify a custom source for a single cookbook:
cookbook 'boxcutter_users', :path => '.'
cookbook 'boxcutter_users_test', :path => 'test/cookbooks/boxcutter_users_test'
