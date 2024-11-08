#
# Cookbook:: boxcutter_onepassword_test
# Recipe:: connect_server
#

puts 'MISCHA: connect_server'
include_recipe 'boxcutter_onepassword::user'
include_recipe 'boxcutter_onepassword::connect_server'
