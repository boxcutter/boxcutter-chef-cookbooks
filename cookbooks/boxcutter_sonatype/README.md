boxcutter_sonatype
==================

The `boxcutter_sonatype` cookbook automates the installation, bootstrap, and
ongoing configuration of a Sonatype Nexus Repository 3 instance using Chef.

At a high level, this cookbook:

- Installs Nexus Repository 3
- Ensures the Nexus service is running
- Bootstraps the admin account (if required)
- Accepts the Nexus EULA (if required)
- Enforces selected security and access settings (for example, anonymous access)
- Ensures the instance is left in a known, converged state

This cookbook is safe to run repeatedly. All configuration steps are
idempotent and driven through the Nexus REST API.

Usage
-----

The following code snippet is the most minimal example that will set up a
Sonatype Nexus 3 repository. It will configure an `admin` account that the
automation will use to make Nexus REST API calls, and configure the server
enough so that the onboarding wizard is never displayed.

```ruby
node.run_state['boxcutter_sonatype'] ||= {}
node.run_state['boxcutter_sonatype']['nexus_repository'] ||= {}
node.run_state['boxcutter_sonatype']['nexus_repository']['admin_username'] = 'admin'
node.run_state['boxcutter_sonatype']['nexus_repository']['admin_password'] = 'superseekret'

include_recipe 'boxcutter_sonatype::default'
```

To use this automation, you need to define a password for the `admin` account.
The `admin` account is used to authenticate all Nexus REST API calls performed
in this cookbook (bootstrapping, configuration, and ongoing enforcement.)

Since this is a secret, it is recommended this key be stored in
`node.run_state` so that it is not persisted on the Chef server after the Chef
run completes.

### Credential lookup order

The automation looks for Nexus admin password in the following order
(highest priority first):

1. `node.run_state['boxcutter_sonatype']['nexus_repository']['admin_password']`
1. `node['boxcutter_sonatype']['nexus_repository']['admin_password']`

If a password is present in `node.run_state`, it will always take precedence
over any value defined in node attributes.

### Providing the admin password via node.run_state

The recommended approach is to inject the password into `node.run_state`
from a wrapper cookbook at converge time:

```ruby
# Initialize the parent hash if it doesn't exist
node.run_state['boxcutter_sonatype'] ||= {}
node.run_state['boxcutter_sonatype']['nexus_repository'] ||= {}

# Provide the Nexus admin password for this Chef run only
node.run_state['boxcutter_sonatype']['nexus_repository']['admin_password'] = 'Superseekret63'
```

Using `node.run_state` ensures the password is available only for the duration
of the Chef run and is not stored or indexed by the Chef Server.

### Admin password recovery

If the Nexus admin password ever becomes out of sync with Chef (for example,
after a manual reset or a failed converge), follow Sonatype’s official recovery
procedure:

https://support.sonatype.com/hc/en-us/articles/213467158-How-to-reset-a-forgotten-admin-password-in-Sonatype-Nexus-Repository-3

After resetting the password, update the value supplied to this cookbook and
re-run Chef.
