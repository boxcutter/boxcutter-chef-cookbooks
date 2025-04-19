#
# Cookbook:: boxcutter_tailscale_test
# Recipe:: auth_key
#

# Test plan:
# In tailscale, go to https://login.tailscale.com/admin/settings/keys
# Generate auth key... with the following settings:
# - Description: test key for chef
# - Reusable: true
# - Tags: tag:chef
# Copy Client ID and Client secret to run_state
# Run `kitchen converge auth-key`
#
# 1. Verify default settings work
#            - create default
#            -   set hostname          to nil
#            -   set tailnet           to nil
#            -   set api_base_url      to "https://api.tailscale.com"
#            -   set ephemeral         to true
#            -   set tags              to ["chef"]
#            -   set timeout           to "60s" (default value)
#            -   set use_tailscale_dns to false
#            -   set shields_up        to true
# 2. Verify default settings are idempotent (run converge a few times with no changes)
# 3. Change hostname
# 4. Toggle ephemeral, should not change until node token is reset with "tailscale logout"
# 5. Toggle use_tailscale_dns
# 6. Toggle shields_up
# 7. Set duplicate name on second host, verify it is idempotent
# 8. Generate ephemeral auth key - verify everything works again

# test oauth client for chef
node.run_state['boxcutter_tailscale'] ||= {}
node.run_state['boxcutter_tailscale']['auth_key'] = 'token_here'
node.default['boxcutter_tailscale']['tags'] = 'chef'
node.default['boxcutter_tailscale']['ephemeral'] = false
# 3. Change hostname
# node.default['boxcutter_tailscale']['hostname'] = 'dokken-rename'
# 4. Toggle ephemeral, should not change until node token is reset with "tailscale logout"
# node.default['boxcutter_tailscale']['ephemeral'] = false
# 5. Toggle use_tailscale_dns
# node.default['boxcutter_tailscale']['use_tailscale_dns'] = true
# 6. Toggle shields_up
# node.default['boxcutter_tailscale']['shields_up'] = false

include_recipe 'boxcutter_tailscale::default'
