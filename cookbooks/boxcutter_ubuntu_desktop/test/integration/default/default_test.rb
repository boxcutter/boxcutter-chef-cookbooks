# Chef InSpec test for recipe boxcutter_ubuntu_desktop::default

# The boxcutter password hash comes from data_bags/fb_users_auth. Make sure it
# lands in /etc/shadow rather than leaving the account locked.
describe shadow.users('boxcutter') do
  its('count') { should eq 1 }
  its('passwords.first') { should match(/^\$6\$/) }
end
