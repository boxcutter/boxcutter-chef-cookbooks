#
# Cookbook:: boxcutter_couchdb_test
# Recipe:: default
#

node.run_state['boxcutter_couchdb'] ||= {}
node.run_state['boxcutter_couchdb']['admin_username'] = 'chef-admin'
node.run_state['boxcutter_couchdb']['admin_password'] = 'superseekret'

# Generate with ::SecureRandom.uuid.tr('-', '')
node.default['boxcutter_couchdb']['local']['couchdb'] = {
  'uuid' => 'b053978bdcd0bfcd08010d195c863218',
}

include_recipe 'boxcutter_couchdb::default'
