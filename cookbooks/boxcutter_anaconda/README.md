boxcutter_anaconda
==================

Manage Anaconda-based Python installs and Conda environments, both user-based
and system-wide.

Usage
-----

Use the `node['boxcutter_anaconda']['config']` attribute to specify a
locations for each Anaconda python install on a host. Provide a directory
name for each install on the system as a hash.

Within the hash, you'll need to specify key-value pairs for various
settings. Similar to pyenv, Anaconda uses login shell shims to do its magic,
so it requires a user context to run within. At the bare minimum, you'll
need to specify the user and group to use for the Anaconda install as
settings.

```ruby
node.default['boxcutter_anaconda']['config'] = {
  '/home/alice/miniconda3' => {
    'user' => 'alice',
    'group' => 'alice',
  }
}
```

By convention, this subdirectory is normally called `miniconda3` or
`anaconda3`, depending on the install. By default, the Miniconda installer will
be used.

Use the `full_install: true` setting to use the Anaconda installer, instead
of the Miniconda installer. Then it will install the roughly 2800 packages
in the full Anaconda environment. But make sure you have sufficient disk
disk space for this install (~6-8GB).

```ruby
node.default['boxcutter_anaconda']['config'] = {
  '/home/alice/anaconda3' => {
    'full_install' => true,
    'user' => 'alice',
    'group' => 'alice',
  }
}
```

You can use the `condarc` setting to manage an optional runtime configuration file
to configure various aspects of conda. Within the key, the contents are directly
converted from JSON to YAML. For more information on specific `.condarc` settings,
refer to the documentation: https://conda.io/projects/conda/en/latest/user-guide/configuration/use-condarc.html

```ruby
node.default['boxcutter_anaconda']['config'] = {
  '/home/alice/miniconda3' => {
    'user' => 'alice',
    'group' => 'alice',
    'condarc' => {
      'auto_activate_base': false,
      'notify_outdated_conda': false,
    },
  },
}
```

Use the `boxcutter_anaconda_package` resource to manage Anaconda packages.
At the very minimum, you'll need to supply the root location for the
Anaconda install as `anaconda_root`, plus the primary `user`/`group` used for
the install that has write privileges to the location.

```ruby
boxcutter_anaconda_package 'flask' do
  anaconda_root '/home/alice/miniconda3'
  user 'alice'
  group 'alice'
end
```
