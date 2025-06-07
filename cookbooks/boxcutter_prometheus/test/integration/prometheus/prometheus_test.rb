# Chef InSpec test for recipe boxcutter_prometheus::prometheus

# The Chef InSpec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec/resources/

describe port(9090) do
  it { should be_listening }
  its('processes') { should include 'prometheus' }
end

describe processes('prometheus') do
  its('entries') { should_not be_empty }
end

describe http('http://localhost:9090/metrics') do
  its('status') { should cmp 200 }
  its('body') { should match(/prometheus_http_request_duration_seconds_bucket/) }
end
