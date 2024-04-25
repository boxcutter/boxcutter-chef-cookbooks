#
# Cookbook:: boxcutter_tailscale_test
# Recipe:: default
#

# This requires a hosted tailscale server and auth keys to test. Easiest
# is to run through the following tests manually:
#
# 1. no_key
# 2. oauth_client
# 3. auth_key

# This default test just installs the tailscale package and calls it a day
include_recipe 'boxcutter_tailscale::packages'
