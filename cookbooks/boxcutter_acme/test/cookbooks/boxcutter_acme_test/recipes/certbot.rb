#
# Cookbook:: boxcutter_acme_test
# Recipe:: certbot
#

# op item get 'Cloudflare API token amazing-sheila' --vault Automation-Org
# op item get gk6bozl2ruh5v3knglpzsaml3u --vault Automation-Org --format json
node.run_state['boxcutter_acme'] ||= {}
node.run_state['boxcutter_acme']['certbot'] ||= {}
node.run_state['boxcutter_acme']['certbot']['cloudflare_api_token'] = \
  Boxcutter::OnePassword.op_read('op://Automation-Org/Cloudflare API token amazing-sheila/credential')

node.default['boxcutter_acme']['certbot']['config'] = {
  'nexus' => {
    'renew_script_path' => '/opt/certbot/bin/certbot_renew.sh',
    'certbot_bin' => '/opt/certbot/venv/bin/certbot',
    'domains' => ['testy.boxcutter.net', '*.testy.boxcutter.net'],
    'email' => 'letsencrypt@boxcutter.dev',
    'cloudflare_ini' => '/etc/chef/cloudflare.ini',
    'extra_args' => [
      '--dns-cloudflare',
      '--dns-cloudflare-credentials /etc/chef/cloudflare.ini',
      '--test-cert',
    ].join(' '),
  },
}

include_recipe 'boxcutter_acme::certbot'
