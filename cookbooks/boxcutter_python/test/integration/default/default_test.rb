# Chef InSpec test for recipe boxcutter_python::default

# The Chef InSpec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec/resources/

pyenv_user = 'python'
pyenv_root = '/home/python/.pyenv'

describe command("PYENV_ROOT=#{pyenv_root} #{pyenv_root}/bin/pyenv --version") do
  its('stdout') { should match(/pyenv /) }
end

describe command("PYENV_ROOT=#{pyenv_root} #{pyenv_root}/bin/pyenv virtualenv --version") do
  its('stdout') { should match(/pyenv-virtualenv /) }
end

describe command("PYENV_ROOT=#{pyenv_root} #{pyenv_root}/bin/pyenv which python") do
  its('exit_status') { should cmp 0 }
end

command = "su --login --command \"PYENV_ROOT=#{pyenv_root} #{pyenv_root}/bin/pyenv versions --bare\" #{pyenv_user}"
describe command(command) do
  its('stdout') { should match('3.8.13') }
  its('stdout') { should match('3.10.4') }
  its('stdout') { should match('venv38') }
  its('stdout') { should match('venv310') }
end
