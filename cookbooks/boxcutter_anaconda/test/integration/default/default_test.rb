# Chef InSpec test for recipe boxcutter_anaconda::default

# The Chef InSpec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec/resources/

anaconda_user = 'boxcutter'
anaconda_group = 'boxcutter'
anaconda_home = '/home/boxcutter'
miniconda_root = '/home/boxcutter/miniconda3'

describe user(anaconda_user) do
  it { should exist }
  its('group') { should eq anaconda_group }
  its('home') { should eq anaconda_home }
  its('shell') { should eq '/bin/bash' }
end

conda_list_command = \
  %{su --login #{anaconda_user} --command "#{miniconda_root}/bin/conda list"}
describe command(conda_list_command) do
  its('stdout') { should match(/^cmake/) }
end
