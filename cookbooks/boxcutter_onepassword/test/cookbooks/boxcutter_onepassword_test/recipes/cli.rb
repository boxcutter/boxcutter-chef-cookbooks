#
# Cookbook:: boxcutter_onepassword_test
# Recipe:: cli
#

puts "MISCHA: #{Boxcutter::OnePassword.op_whoami}"

include_recipe 'boxcutter_onepassword::cli'
