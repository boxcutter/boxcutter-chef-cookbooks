describe command('/opt/op/bin/op -h') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match(/1Password CLI/) }
end

describe command('/usr/local/bin/op') do
  it { should exist }
end
