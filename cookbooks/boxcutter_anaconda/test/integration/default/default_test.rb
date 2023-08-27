# Chef InSpec test for recipe boxcutter_anaconda::default

# The Chef InSpec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec/resources/

anaconda_user = 'anaconda'
anaconda_group = 'anaconda'
anaconda_home = '/home/anaconda'
miniconda_root = '/home/anaconda/miniconda3'

describe user(anaconda_user) do
  it { should exist }
  its('uid') { should eq 993 }
  its('gid') { should eq 993 }
  its('group') { should eq anaconda_group }
  its('home') { should eq anaconda_home }
  its('shell') { should eq '/bin/bash' }
end

pyenv_versions_command = \
  %(su --login #{anaconda_user} --command "#{miniconda_root}/bin/conda list")
describe command(pyenv_versions_command) do
  its('stdout') { should match(/^cmake/) }
end
