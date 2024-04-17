#  boxcutter_tailscale

Configures the Tailscale VPN https://tailscale.com/

## Attributes

- node['boxcutter_tailscale']['oauth_clients']
- node['boxcutter_tailscale']['auth_keys']
- node['boxcutter_tailscale']['ephemeral']
- node['boxcutter_tailscale']['tags']
- node['boxcutter_tailscale']['enable']
- node['boxcutter_tailscale']['hostname']
- node['boxcutter_tailscale']['api_base_url']
- node['boxcutter_tailscale']['tailnet']
- node['boxcutter_tailscale']['accept_dns']
- node['boxcutter_tailscale']['shields_up']

## Usage

You'll need to create an [OAuth client](https://tailscale.com/kb/1215/oauth-clients)
or a [pre-authentication key](https://tailscale.com/kb/1085/auth-keys) for Chef to
to register new Tailscale nodes without needing manual steps. NOTE: You only need
to use one or the other, not BOTH. And in general, OAuth Clients are preferred
as you have more control over the key lifetime.

Since this is a secret, it is recommended this key be stored in
`node.run_state` so that it is not stored on the Chef server after the Chef run.

The automation will look for credentials in the following preference order:
1. `node.run_state['boxcutter_tailscale']['oauth_clients']`
2. `node.run_state['boxcutter_tailscale']['auth_keys']`
3. `node['boxcutter_tailscale']['oauth_clients']`
4. `node['boxcutter_tailscale']['auth_keys']`

You can generate a new OAuth Client using the [OAuth clients](https://login.tailscale.com/admin/settings/oauth)
page of the admin console. `Devices: Write` permission is sufficient permissions
for this cookbook, so it can add/remove devices from the tailnet. You'll also need
to define one more more [ACL tags](https://tailscale.com/kb/1068/acl-tags) in your
Tailnet policy file to define ownership for any managed devices.

For an OAuth Client, provide the `Client ID` and `Client Secret` as a hash in an
array, like so. The attribute is defined as an array so that you can provide multiple
credentials, if desired. The automation code will try each credential until one is
successful. This allows use of a primary and secondary credential to ensure zero downtime
while a new credential is being propagated to the entire fleet.

The automation will automatically allocate a new one-time preauthorization key using
the OAuth Client on each Chef run, when something needs to be changed on your tailnet.
Conflicts with `aut_keys`, if provided.

```
# Initialize the parent hash if it doesn't exist
node.run_state['boxcutter_tailscale'] ||= {}
node.run_state['boxcutter_tailscale']['oauth_clients'] = [
  {
    'oauth_client_id' => 'kEbPBn6g1234CNTRL',
    'oauth_client_secret' => 'tskey-client-kEbPBn6g1234CNTRL-xhYtNZWtJpbG12342XAwbLpraivu3FYQ',
  },
]
# Must have at least one ACL tag, otherwise you will get an error when the node is created.
# Also tags MUST match the ones defined when the OAuth Client was defined, otherwise you'll
# get a 400 error.
# ACL tag(s) defined in your Tailnet policy file that owns this node
node.default['boxcutter_tailscale']['tags'] = 'chef'
```

Pre-authorization keys ("auth keys") are also supported. If an auth key is used,
the "ephemeral" setting and "tags" must match the setting used when the key was generated.
Conflicts with `oauth_clients`, if provided.

```
# Initialize the parent hash if it doesn't exist
node.run_state['boxcutter_tailscale'] ||= {}
node.run_state['boxcutter_tailscale']['auth_keys'] = [
  'tskey-auth-kFac9sh1234CNTRL-fKBnjZUfDbVXyYJg2qhqSVDDk12tZoSL1',
]
# Automatically inherits ephemeral setting and tags from when the auth key was generated
# They MUST match in the attributes otherwsie you'll get an error when the node is
# created - for pre-created authorization keys only.
```

Once you have provided an OAuth client or a pre-authentication key to the cookbook,
along with the `node['boxcutter_tailscale']['tags']` and `node['boxcutter_tailscale']['ephemeral']`
attributes, set by the key type, include `boxcutter_tailscale::default` to provision
the node as a machine on the default tailnet.

You can customize the configuration with the following attributes:

### enable

If you would like to include the cookbook but disable the `tailscaled` service, 
set enable to `false`.

### hostname

By default, this cookbook will configure the machine name to be automatically
generated from its OS hostname. If a device already on the tailnet has the same
name , the new machine will get a name like `<hostname>-1`. If the conflicting
machine's name is later changed, this machine will still maintain the
`<hostname>-1` machine name. If the value of the `hostname`
attribute is `nil`, this auto-naming scheme is used.

If you would like to override this auto-naming behaviour and use a specific,
possibly duplicate machine name, specify the hostname you want to use with
`node['boxcutter_tailscale']['hostname']`.

### api_base_url

When OAuth clients are used, the cookbook makes calls directly to the Tailscale
API for more robust error handling. By default the base URL for the Tailscale
API is `https://api.tailscale.com`. You can change this default by setting
`node['boxcutter_tailscale']['api_base_url']`.

### tailnet

When OAuth clients are used, the default organization name is used (specified with
a `-`). You can change this by setting `node['boxcutter_tailscale']['tailnet']`.
The value should match the organization name defined in the admin GUI of the
desired Tailnet.

### use_tailscale_dns

When set to `false` the node is configured to stop accepting DNS settings from
Tailscale (a.k.a. disabling MagicDNS). This is the default setting in this cookbook.

Disabling use of the Tailscale DNS is set to `false` by default because
MagicDNS relies on the carrier-grade NAT address `100.100.100.100`. Cell networks
and satellite also commonly use this address space, and unfortunately it is
not uncommon to have a conflicting IP using `100.100.100.100` on these networks.

### shields_up

When set to `true` incoming connections are blocked by default. This is the default
setting in this cookbook. Otherwise when sel to `false`, incoming connections are
allowed.
