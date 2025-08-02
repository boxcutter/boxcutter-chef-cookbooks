# Policyfile.rb - Describe how you want Chef Infra Client to build your system.
#
# For more information on the Policyfile feature, visit
# https://docs.chef.io/policyfile/

# A name that describes what the system you're building with Chef does.
name 'boxcutter_sonatype'

# Where to find external cookbooks:
default_source :chef_repo, '../../../chef-cookbooks/cookbooks'
default_source :chef_repo, '../'

# run_list: chef-client will run these recipes in the order specified.
run_list 'boxcutter_ohai', 'boxcutter_init', 'boxcutter_sonatype_test::default'

# Specify a custom source for a single cookbook:
cookbook 'boxcutter_sonatype', :path => '.'
cookbook 'boxcutter_sonatype_test', :path => 'test/cookbooks/boxcutter_sonatype_test'
