# Chef InSpec test for recipe polymath_ros::build_essential

# The Chef InSpec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec/resources/

%w(colcon vcs).each do |tool|
  describe command("which #{tool}") do
    its('exit_status') { should eq 0 }
    its('stdout') { should match %r{^/} }  # should return a path like /usr/bin/git
  end

  describe command("#{tool} -h") do
    its('exit_status') { should eq 0 }
  end
end
