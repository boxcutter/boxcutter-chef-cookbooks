#
# Cookbook:: boxcutter_onepassword_test
# Recipe:: service_account
#

include_recipe 'boxcutter_onepassword::cli'

# There's no great ways to test these runtime functions that I know of.
# Can't really use chefspec because it installs the 1Password CLI at
# runtime and we don't want to install tools on the testing host running
# rspec. So I'm just using the runtime functions to check known keys
# and raising errors when they don't match.
#
# op item get 'craft SSH Key' --vault Automation-Org --format json
public_key = Boxcutter::OnePassword.op_read('op://Automation-Org/craft SSH Key/public key')
if public_key != 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQD2y6TEs9+Mc6FRUbRBDsb+6a3erlYnv39IDge7LxIvI' \
                 'A1/XH5+6ChbQykSyge9gxZFlnVg92nvN82E+B5DKik9HUvkrN4CSOyOUb2ggkMXLLzHJFI29LjU3HruX7' \
                 'DHIHwyJz2mZT9LDqBVX+/urAuRFRPe9hp4eHC0upWijgp2TmV+ghOOY7R8LxmuUbaG/QaxxXGVcYffmC5' \
                 'kzalmOqqcEPue0JfHmWu/QdmMWEjrbVjZevjhLy7rb00hLWeDleURjK8OqupBGAHu16g50QFFXGs1TfzY' \
                 'TFll2Ehy28ZL7gxKObHsJREyn+5eP9lrU4dcZqQZHb/aUUgAOAdYP0ZosUrXBqwf9Rcnck9U+dC8a8WY8' \
                 'ibQvFJ5vtMsDDQhrUlPPAgVJpXf6BAhB+VH1SHBfDFBHOcv6w50/AlJUze6GXYZ6CQOF1K5CsoEInuiD5' \
                 'SJCmDt92/2v5+EIe4GLPRKzed896CMgfRPfam59KzeaeNUNf5E1RMmPGbPleZMMa4yx5DpSkDvrXTalbT' \
                 'DP1SYvrSLiHrFdl97XGx9nmF8yFUlDS+CrJK/W3eT9pt7qvR7FDIBI//HmFtICIkP5pu3gi978QHo5VYe' \
                 'w6p4LPNVJ47LYU6yBfy3DVZv42y13EHlqxQXw0S3FT/t6Vb/y45h8FvAY0eMgU1cyN7KHP9Y1w=='
  fail 'Unable to read "craft SSH Key" - did you remember to set OP_SERVICE_ACCOUNT_TOKEN?'
end
