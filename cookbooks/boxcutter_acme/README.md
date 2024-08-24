# boxcutter_acme

Configures ACME-based clients (Automated Certificate Management Environment)
that make it possible to automate the issuance and renewal of SSL certificates
without needing human interaction.

## Recipes

- `boxcutter_acme::lego` - Let’s Encrypt client and ACME library written in Go.

## Usage

Add `include_recipe 'boxcutter_acme::lego'` to install the Let's Encryt client
and ACME library for Go. The LEGO binaries will be installed to `/opt/lego`
and a symlink to the latest installed version will be created as `/opt/lego/latest`

The LEGO binary will be installed as `/opt/lego/latest/bin/lego`.

You can specify SSL certificate configurations to be managed under
`node['boxcutter_acme']['lego']['config']`.

For example:

```
node.default['boxcutter_acme']['lego']['config'] = {
  'example' => {
    'certificate_name' => 'server.example.com',
    'data_path' => '/etc/lego',
    'renew_script_path' => '/opt/lego/lego_renew.sh',
    'email' => 'letsencrypt@example.com',
    'domains' => %w(
      server.example.com
    ),
  },
}
```

### Fields

Required fields:

* `certificate_name`: Name of the certificate to be matched by `lego list`.
  Usually matches domains, but depends on whether or not wildcard domains
  are used.
* `data_path`: Directory to use for storing the certificate data.
* `renew_script_path`: Full path where the automation should put the script
  that obtains and renews
* `email`: Email used for registration and recovery contact.
* `domains`: Array containing the list of domain values to be added to the SSL
  certificate

Optional fields:

* `renew_days`: The number of days left on a certificate to renew it. (default: 30)
* `server`: Let's Encrypt ACME server to be used. If you'd like to test
  something without issuing real certificates, you can use the staging
  endpoint `https://acme-staging-v02.api.letsencrypt.org/directory`.
* `extra_parameters`: Additional global options to be added to the command
  line, not covered by required fields (`--dns-resolvers value`). Default is `--http`.
* `extra_environment`: Additional environment variables to be configured for
  the renew script. Usually environment variables required for the DNS
  tokens.
