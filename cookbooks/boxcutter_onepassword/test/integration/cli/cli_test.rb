describe command('/usr/bin/op -h') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match(/1Password CLI/) }
end

describe command('/usr/bin/op') do
  it { should exist }
end
