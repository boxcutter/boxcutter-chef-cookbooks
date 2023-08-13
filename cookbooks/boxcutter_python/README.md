#  boxcutter_python

Manage multiple side-by-side Python environments with pyenv.

## Description

This cookbook uses [pyenv](https://github.com/pyenv/pyenv) to install and
manage multiple versions of Python side-by-side on a single host. This allows
use of Python code without touching the system Python in multiple, isolated
environments with possibly completely different packages and dependencies.

Use the `node['boxcutter_python']['pyenv']` attribute to define locations for
each python install to be managed by pyenv. By convention this is normally
`$HOME/.pyenv` under a user account. The pyenv program uses login shells to
do its magic, so it requires a user context to run within.

```
node.default['boxcutter_python']['pyenv'] = {
  '/home/alice/.pyenv' => {
    'user' => 'alice',
    'group' => 'alice',
    'default_python' => '3.10.4',
    'pythons' => {
      '3.10.4' => nil,
    },
  },
}
```
