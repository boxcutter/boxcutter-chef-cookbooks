#
# Cookbook:: boxcutter_acme_test
# Recipe:: default
#

node.default['boxcutter_acme']['lego']['config'] = {
  'nexus' => {
    'certificate_name' => 'hq0-nexus01.sandbox.polymathrobotics.dev',
    'data_path' => '/etc/lego/tmp',
    'renew_script_path' => '/opt/lego/lego_renew.sh',
    'renew_days' => '30',
    'server' => 'https://acme-staging-v02.api.letsencrypt.org/directory',
    'email' => 'letsencrypt@polymathrobotics.com',
    'domains' => %w{
      hq0-nexus01.sandbox.polymathrobotics.dev
      *.hq0-nexus01.sandbox.polymathrobotics.dev
    },
    'extra_parameters' => [
      '--dns cloudflare',
      # There's are issues resolving apex domain servers over tailscale, so
      # override the DNS resolver lego uses, in case we're running tailscale
      '--dns.resolvers 1.1.1.1',
    ],
    'extra_environment' => {
      'export CF_DNS_API_TOKEN' => '<token>',
    },
  },
}

include_recipe 'boxcutter_acme::lego'
