describe command('gh --version') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match(/gh version/) }
end

describe command('gh') do
  it { should exist }
end
