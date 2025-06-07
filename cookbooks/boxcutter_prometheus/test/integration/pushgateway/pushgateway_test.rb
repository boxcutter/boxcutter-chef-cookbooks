# Chef InSpec test for recipe boxcutter_prometheus::pushgateway

# The Chef InSpec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec/resources/

describe port(9091) do
  it { should be_listening }
  its('processes') { should include 'pushgateway' }
end

describe processes('pushgateway') do
  its('entries') { should_not be_empty }
end
