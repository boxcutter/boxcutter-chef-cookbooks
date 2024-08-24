# boxcutter_sonatype

## Usage

To use this automation, you need to define a user account that has admin
privileges so that Chef can configure the repository manager through the
REST API.





To use this automation, you need to define a password for the `admin` account.
The `admin` account is used to authorize all the API calls that drive this
automation.

Since this is a secret, it is recommended this key be stored in
`node.run_state` so that it is not stored on the Chef server after the Chef run.

The automation will look for credentials in the following preference order:
1. `node.run_state['boxcutter_sonatype']['nexus_repository']['admin_password']`
4. `node['boxcutter_sonatype']['nexus_repository']['admin_password']`

Provide the `admin` password in `node.run_state`, like so. The automation will
automatically 

The automation will automatically allocate a new one-time preauthorization key using
the OAuth Client on each Chef run, when something needs to be changed on your tailnet.
Conflicts with `auth_key`, if provided.

```
# Initialize the parent hash if it doesn't exist
node.run_state['boxcutter_tailscale'] ||= {}
node.run_state['boxcutter_sonatype'] ||= {}
node.run_state['boxcutter_sonatype']['nexus_repository'] ||= {}
node.run_state['boxcutter_sonatype']['nexus_repository']['admin_password'] = 'Superseekret63'
```
NOTE: Instructions for recovery if Chef ever gets out of sync with the current
admin password are located as this [link](https://support.sonatype.com/hc/en-us/articles/213467158-How-to-reset-a-forgotten-admin-password-in-Sonatype-Nexus-Repository-3).

