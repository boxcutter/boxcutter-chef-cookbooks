#
# Cookbook:: boxcutter_tailscale_test
# Recipe:: no_key
#

# Test plan:
# Run `kitchen converge no-key`
#
# Expected results:
# Should report a runtime error that a key is not found:
#   RuntimeError: boxcutter_tailscale: needs tailscale up but
#   oauth_client_id/oauth_client_secret or auth_key not found

include_recipe 'boxcutter_tailscale::default'
