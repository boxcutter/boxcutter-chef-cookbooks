#
# Cookbook Name:: boxcutter_ci_fixes
# Recipe:: default
#

# On centos-stream-10 you'll see the following error using the fb_systemd
# cookbook. To allow kitchen tests to run in CI, disable systemd-logind:
#
# STDERR: Failed to restart systemd-logind.service: Unit systemd-logind.service
# is masked.
# ---- End output of ["/usr/bin/systemctl", "--system", "restart",
# "systemd-logind"] ----
# Ran ["/usr/bin/systemctl", "--system", "restart", "systemd-logind"] returned 1
#
node.default['fb_systemd']['logind']['enable'] = false
