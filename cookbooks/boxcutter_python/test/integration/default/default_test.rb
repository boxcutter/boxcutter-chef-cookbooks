# Chef InSpec test for recipe boxcutter_python::default

# The Chef InSpec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec/resources/

pyenv_user = 'python'
pyenv_group = 'python'
pyenv_home = '/home/python'
pyenv_root = '/home/python/.pyenv'

describe user(pyenv_user) do
  it { should exist }
  its('uid') { should eq 994 }
  its('gid') { should eq 994 }
  its('group') { should eq pyenv_group }
  its('home') { should eq pyenv_home }
  its('shell') { should eq '/bin/bash' }
end

describe command("PYENV_ROOT=#{pyenv_root} #{pyenv_root}/bin/pyenv --version") do
  its('stdout') { should match(/pyenv /) }
end

describe command("PYENV_ROOT=#{pyenv_root} #{pyenv_root}/bin/pyenv virtualenv --version") do
  its('stdout') { should match(/pyenv-virtualenv /) }
end

pyenv_versions_command = \
  %{su --login #{pyenv_user} --command "PYENV_ROOT=#{pyenv_root} #{pyenv_root}/bin/pyenv versions --bare"}
describe command(pyenv_versions_command) do
  its('stdout') { should match('3.8.13') }
  its('stdout') { should match('3.10.4') }
  its('stdout') { should match('venv38') }
  its('stdout') { should match('venv310') }
end
