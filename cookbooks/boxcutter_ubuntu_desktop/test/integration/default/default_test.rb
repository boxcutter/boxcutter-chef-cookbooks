# Chef InSpec test for recipe boxcutter_ubuntu_desktop::default

# The boxcutter password hash is read from 1Password, which kitchen has no
# token for, so only check the account fb_users creates.
describe user('boxcutter') do
  it { should exist }
  its('home') { should eq '/home/boxcutter' }
  its('shell') { should eq '/bin/bash' }
end
