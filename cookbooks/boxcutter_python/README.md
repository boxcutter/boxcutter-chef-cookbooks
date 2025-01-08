# boxcutter_python

Configure Python, Python packages and virtual environments using the
system Python and/or multiple side-by-side Python environments with
pyenv.

## Configuring system Python

Some basic primitive resources are provided for working with the system python:
- `boxcutter_python_virtualenv`
- `boxcutter_python_package`

To use these resources, include the `boxcutter_python::system` recipe.

Here's an example that creates a virtualenv and installs a python package:

```ruby
include_recipe 'boxcutter_python::system'

boxcutter_python_virtualenv '/opt/certbot/venv'

boxcutter_python_package 'certbot' do
  version '3.0'
end
```

## Configuring pyenv

This cookbook uses [pyenv](https://github.com/pyenv/pyenv) to install and
manage multiple versions of Python side-by-side on a single host. This allows
use of Python code without touching the system Python. And then virtualenv
can be used to create multiple, isolated environments within that python
install.

Use the `node['boxcutter_python']['pyenv']` attribute to define a hash
with a key specifying locations for each python install to be managed by
pyenv. By convention this is normally $HOME/.pyenv under a user account.
The pyenv program uses login shells to do its magic, so it requires a
user context to run within.

Within the hash, you'll need to specify key-value pairs denoting
the version of python to install, the default version of python to
use within the pyenv environment, and the user/group to use
for permissions.

Here's an example that installs Python 3.10.4 for the user `alice`:

```ruby
node.default['boxcutter_python']['pyenv'] = {
  '/home/alice/.pyenv' => {
    'user' => 'alice',
    'group' => 'alice',
    'default_python' => '3.10.11',
    'pythons' => {
      '3.10.11' => nil,
    },
  },
}
```

Sometimes you'll need to refer to the locations where the python installations
(a.k.a. "pythons") are installed to integrate with other tools like editors
or development environments.

The python installations are installed in `~alice/.pyenv/versions`
There will be a subdirectory underneath patching the "pythons" string. In this
example, `~alice/.pyenv/versions/3.10.4`.

Multiple versions of python can be installed side-by-side, by adding multiple
version strings to the "pythons" hash, like so:

```ruby
node.default['boxcutter_python']['pyenv'] = {
  '/home/alice/.pyenv' => {
    'user' => 'alice',
    'group' => 'alice',
    'default_python' => '3.10.11',
    'pythons' => {
      '3.10.11' => nil,
      '3.11.4' => nil,
    },
  },
}
```

To use the installed versions of python, you'll need to set up your shell
environment for pyenv. Usually you'll add these statements to your `~/.bashrc`
or equivalent for your shell environment:

```bash
# PYENV_ROOT should point to the root path of the pyenv environment, usually
# $HOME/.pyenv
export PYENV_ROOT="$HOME/.pyenv"
# Add the pyenv executable to your PATH
export PATH="$PYENV_ROOT/bin:$PATH"
# Install pyenv into your shell as a shell function, enable shims and
# autocompletion
eval "$(pyenv init -)"
```

### Sharing python environments with all users and system scripts

Some of the plugins for pyenv assume that the binaries for `pyenv` are located
in the same place where the python environments are installed, so you can't
really use pyenv outside of the context of a user:
https://github.com/pyenv/pyenv/issues/1843

However, you can install bare versions of python in shared locations and
manage them as plain python virtualenvs. This is supported via the 
`node['boxcutter_python']['python_build']` attribute. It uses the same
form as the `pyenv` attribute, just without the keys that wouldn't be
applicable system-wide.

```ruby
node.default['boxcutter_python']['python_build'] = {
  '/opt/python' => {
    'user' => 'alice',
    'group' => 'alice',
    'pythons' => {
      '3.10.11' => nil,
      '3.11.4' => nil,
    },
  },
}
```

## Recipes

### `pyenv`

The `pyenv` recipe installs pyenv so that you can easily switch between multiple
versions of Python.

### `system`

The `system` recipe installs the system Python - the default version of Python
for a particular operating system.

## Resources

### `boxcutter_python_virtualenv` 

The `boxcutter_python_virtualenv` resource creates a Python virtual environment.

```ruby
boxcutter_python_virtualenv `/opt/certbot/venv`
```

#### Actions

- `:create` - Create a Python virtual environment. *(default)*
- `:delete` - Delete a Python virtual environment.

#### Properties

- `path` - The path to create the virtual environment.
- `interpreter` - The Python interpreter used to run commands to configure the virtualenv.
- `user` - The user name or user ID used to run commands in the Python interpreter.
- `group` - The group name or group ID used to run commands in the Python interpreter.
- `system_site_packages` - Install globally available packages to the system site-packages directory.
- `copies` - Use copies rather than symlinks.
- `clear` - Delete the contents of the virtual environment directory if it already exists, before creating.
- `upgrade_deps` - Upgrade pip + setuptools to the latest on PyPI.
- `without_pip` - Do not install pip in the virtualenv.
- `prompt` - Set the prompt inside the virtualenv.

### `boxcutter_python_pip`

The `boxcutter_python_pip` resource installs Python packages using `pip`.

```ruby
boxcutter_python_pip `certbot` do
  version '3.0'
end
```

#### Actions

- `:install` - Install a Python package. *(default)*
- `:upgrade` - Install a Python package using the `--upgrade` flag.
- `:remove` - Remove a Python package.

#### Properties

- `package_name` - 'The name of the Python package to install.'
- `version` - 'The version of the Python package to install/upgrade.'
- `pip_binary` - 'Path to the pip binary. Mutually exclusive with `virtualenv`.'
- `virtualenv` - 'Path to a virtual environment in which to install the Python package.'
- `user` - 'The user name or user ID used to run pip commands.'
- `group` - 'The group name or group ID used to pip commands.'
- `extra_options` - 'Extra options to pass to the pip command.'
- `timeout` - 'The number of seconds to wait for the pip command to complete.'
- `environment` - 'Hash containing environment varibles to set before the pip command is run.'

