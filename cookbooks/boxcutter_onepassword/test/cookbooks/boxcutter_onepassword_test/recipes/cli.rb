#
# Cookbook:: boxcutter_onepassword_test
# Recipe:: cli
#

# Try calling the api to trigger bootstrap install
puts "MISCHA: #{Boxcutter::OnePassword.op_whoami}"

include_recipe 'boxcutter_onepassword::cli'
