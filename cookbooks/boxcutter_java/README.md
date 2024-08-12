# boxcutter_java

Manage multiple side-by-side Java environments with
[sdkman](https://sdkman.io/).

## Description

This cookbook uses [sdkman](https://sdkman.io/) to install and manage multiple
versions of Java side-by-side on a single host.

Use the `node['boxcutter_java']['sdkman']` attribute to define locations for
each JVM install to be managed by sdkman. By convention this is normally
`$HOME/.sdkman` under a user account. The sdkman program uses login shells to
do its magic, so it requires a user context to run within.

```
node.default['boxcutter_java']['sdkman'] = {
  '/home/java/.sdkman' => {
    'user' => 'java',
    'group' => 'java',
    'candidates' => {
      'java' => '11.0.24-tem',
    },
  },
}
```

In addition, to defining the above, you will need to add the following line to
the user's `~/.bashrc`:

```
source "$HOME/.sdkman/bin/sdkman-init.sh"
```

To get a listing of available candidate SDKs:

```
sdk list
```

One you have a candidate SDK name, to get a list of available versions for a
candidate SDK:

```
sdk list java
```