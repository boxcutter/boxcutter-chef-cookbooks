#
# Cookbook:: boxcutter_onepassword_test
# Recipe:: default
#
# include_recipe 'boxcutter_onepassword::cli'

include_recipe 'boxcutter_onepassword::cli'

# op item list 'Service Account Auth Token: automation-org-readonly-blue' --vault Automation-Org
Boxcutter::OnePassword.op_read('op://Automation-Org/mzqlddelxv6oe7dfz3vc7iad7m/credential')

