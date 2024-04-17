# Chef InSpec test for recipe boxcutter_tailscale::default

describe command('tailscale') do
  it { should exist }
end

describe command('/usr/bin/tailscale version') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match(/tailscale/) }
end
