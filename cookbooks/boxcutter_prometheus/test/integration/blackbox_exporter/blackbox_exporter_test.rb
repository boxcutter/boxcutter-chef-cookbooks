# Chef InSpec test for recipe boxcutter_prometheus::blackbox_exporter

# The Chef InSpec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec/resources/

describe port(9115) do
  it { should be_listening }
  its('processes') { should include 'blackbox_export' }
end

describe processes('blackbox_exporter') do
  its('entries') { should_not be_empty }
end
