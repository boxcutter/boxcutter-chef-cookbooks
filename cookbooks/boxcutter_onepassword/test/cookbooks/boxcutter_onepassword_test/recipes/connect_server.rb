#
# Cookbook:: boxcutter_onepassword_test
# Recipe:: connect_server
#

puts 'MISCHA: connect_server'
include_recipe 'boxcutter_onepassword::user'

# 'sandbox-connect-server Credentials File', 'Automation-Org'
# op document get 'sandbox-connect-server Credentials File' --vault Automation-Org
node.default['boxcutter_onepassword']['connect_server']['onepassword_credentials']['item'] = \
  'sandbox-connect-server Credentials File'
node.default['boxcutter_onepassword']['connect_server']['onepassword_credentials']['vault'] = \
  'Automation-Org'
include_recipe 'boxcutter_onepassword::connect_server'

# stuff = Boxcutter::OnePassword.op_read('op://Automation-Org/nexus admin blue/password', 'connect_server')
# puts "MISCHA: stuff=#{stuff}"

# op item get 'sandbox-connect-server Access Token: sandbox-connect-server-access-token' --vault Automation-Org
# op item get 7etjvtlft4u4wlbkxvprahvmzq --vault Automation-Org --format json
# op read 'op://Automation-Org/7etjvtlft4u4wlbkxvprahvmzq/credential'
# item = Boxcutter::OnePassword.op_read('op://Automation-Org/7etjvtlft4u4wlbkxvprahvmzq/credential')

# export OP_API_TOKEN="<token>"
# curl \
#     -H "Accept: application/json" \
#     -H "Authorization: Bearer $OP_API_TOKEN" \
#     http://localhost:8080/v1/vaults
#
# export OP_CONNECT_TOKEN=<token>
# export OP_CONNECT_HOST=http://localhost:8080
# op vault list <-- won't work
# op read 'op://Automation-Org/nexus admin blue/password'
