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
