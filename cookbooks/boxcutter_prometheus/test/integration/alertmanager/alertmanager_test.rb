# Chef InSpec test for recipe boxcutter_prometheus::alertmanager

# The Chef InSpec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec/resources/

describe port(9093) do
  it { should be_listening }
  its('processes') { should include 'alertmanager' }
end

describe processes('alertmanager') do
  its('entries') { should_not be_empty }
end

describe command('/opt/alertmanager/latest/amtool check-config /etc/alertmanager/alertmanager.yml') do
  its('exit_status') { should eq 0 }
end
