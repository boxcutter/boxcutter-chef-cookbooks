#
# Cookbook:: boxcutter_postgresql_test
# Recipe:: server
#

include_recipe 'boxcutter_postgresql::server'

# https://www.red-gate.com/simple-talk/databases/postgresql/postgresql-basics-roles-and-privileges/
boxcutter_postgresql_role 'dev1'
