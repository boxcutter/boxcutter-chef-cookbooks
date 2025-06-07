# Chef InSpec test for recipe boxcutter_prometheus::node_exporter

# The Chef InSpec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec/resources/

describe port(9100) do
  it { should be_listening }
  its('processes') { should include 'node_exporter' }
end

describe processes('node_exporter') do
  its('entries') { should_not be_empty }
end

describe http('http://localhost:9100/metrics') do
  its('status') { should cmp 200 }
  its('body') { should match(/node_cpu_seconds_total/) }
end
