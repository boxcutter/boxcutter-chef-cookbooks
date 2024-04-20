# boxcutter_onepassword

Integrates 1Password secrets into Chef, eliminating plaintext secrets in
code.

## Usage

Create a [1Password Service account](https://developer.1password.com/docs/service-accounts) token
or a [1Password Connect server](https://developer.1password.com/docs/connect)
token.

If you have configured a 1Password Connect token, it takes precedence over a
1Password Service Account token. Clear out the Connect environment variables/files
to configure a service account instead.

### Configuring a 1Password Service account token

For a 1Password Service account token, store the token as a file in the same location
as the Chef encrypted data bag key is stored or as an environment variable. When
both a files and an environment variable are defined, the environment variable
takes precedence.

1Password Service account token environment variable:
- `OP_SERVICE_ACCOUNT_TOKEN`

1Password Service
- `/etc/chef/op_service_account_token`

### Configuring a 1Password Connect Server token 

For a 1Password Connect server token, store the connect host and connect token as files
in the same location as the Chef encrypted data bag key is stored or as environment variables.
When both files and environment variables are defined, the environment variables
take precedence.

1Password Connect environment variables:
- `OP_CONNECT_HOST`
- `OP_CONNECT_TOKEN`

1Password Connect files:
- `/etc/chef/op_connect_host`
- `/etc/chef/op_connect_token`

The default location is usually `/etc/chef` and it can be configured with the
`encrypted_data_bag` setting in the Chef `client.rb`

### Secret retrieval

Use the `boxcutter_onepassword::cli` recipe to install the 1Password CLI
on the target machine.

In your cookbooks, use the `op_read` function to read the value of a field in 1Password
specified by a secret reference as if you were running the `op read` command with the CLI.

```ruby
item = Boxcutter::OnePassword.op_read('op://Vault/id123456789/secret')
```

### Troubleshooting credentials

The `op_read()` function outputs a lot of debugging information as it probes
for the various tokens needed to access the secret store. The `op user get --me`
function is also run if a valid token is found, which may aid in troubleshooting
if you are not getting the expected results querying for a secret. Set the log
level to debug to see this debugging information. Here's an example of the output:

```bash
DEBUG: boxcutter_onepassword: probing for 1Password connect server token
DEBUG: boxcutter_onepassword: 1Password connect server token NOT found
DEBUG: boxcutter_onepassword: probing for 1Password Service Account token
DEBUG: boxcutter_onepassword: /etc/chef/op_service_account_token file found!
DEBUG: boxcutter_onepassword: Using 1Password token found in /etc/chef/op_service_account_token
DEBUG: boxcutter_onepassword[op_read]: op user get --me
ID:                     ABCD1234
Name:                   my-user
Email:                  my-user@1passwordserviceaccounts.com
State:                  ACTIVE
Type:                   SERVICE_ACCOUNT
Created:                1 hour ago
Updated:                1 hour ago
Last Authentication:    32 minutes ago
```

