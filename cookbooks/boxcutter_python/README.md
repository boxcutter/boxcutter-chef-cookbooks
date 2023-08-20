#  boxcutter_python

Manage multiple side-by-side Python environments with pyenv.

## Description

This cookbook uses [pyenv](https://github.com/pyenv/pyenv) to install and
manage multiple versions of Python side-by-side on a single host. This allows
use of Python code without touching the system Python. And then virtualenv
can be used to create multiple, isolated environments within that python
install.

Use the `node['polymath_python']['pyenv']` attribute to define a hash
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
in the same place where the python environments are installed:
https://github.com/pyenv/pyenv/issues/1843


