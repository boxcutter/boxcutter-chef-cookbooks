# Chef InSpec test for recipe boxcutter_ros::rocker

describe command('which rocker') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match %r{/rocker} }
end
