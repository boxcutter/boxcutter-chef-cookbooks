# Policyfile.rb - Describe how you want Chef Infra Client to build your system.
#
# For more information on the Policyfile feature, visit
# https://docs.chef.io/policyfile/

# A name that describes what the system you're building with Chef does.
name 'boxcutter_python'

# Where to find external cookbooks:
default_source :chef_repo, '../../../chef-cookbooks/cookbooks'
default_source :chef_repo, '../'

# run_list: chef-client will run these recipes in the order specified.
run_list 'boxcutter_ohai', 'boxcutter_init', 'boxcutter_python_test::default'
named_run_list 'boxcutter_python_test_pyenv', 'boxcutter_ohai', 'boxcutter_init', 'boxcutter_python_test::pyenv'
named_run_list 'boxcutter_python_test_system', 'boxcutter_ohai', 'boxcutter_init', 'boxcutter_python_test::system'

# Specify a custom source for a single cookbook:
cookbook 'boxcutter_python', path: '.'
cookbook 'boxcutter_python_test', path: 'test/cookbooks/boxcutter_python_test'
