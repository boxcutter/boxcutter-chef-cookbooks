# Chef InSpec test for recipe boxcutter_prometheus::redis_exporter

# The Chef InSpec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec/resources/

describe port(9121) do
  it { should be_listening }
  its('processes') { should include 'redis_exporter' }
end

describe processes('redis_exporter') do
  its('entries') { should_not be_empty }
end

describe http('http://localhost:9121/metrics') do
  its('status') { should cmp 200 }
  its('body') { should match(/redis_commands_duration_seconds_total/) }
end
