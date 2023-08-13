#  boxcutter_python

Manage multiple side-by-side Python environments with pyenv,

```
node.default['boxcutter_python']['pyenv'] = {
  '/home/alice/.pyenv' => {
    'user' => 'alice',
    'group' => 'alice',
    'default_python' => '3.8.13',
    'pythons' => {
      '3.8.13' => nil,
      '3.10.4' => nil,
    },
    'virtualenvs' => {
      'venv38' => {
        'python' => '3.8.13',
      },
      'venv310' => {
        'python' => '3.10.4',
      },
    },
  },
}
```
