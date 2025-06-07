# Chef InSpec test for recipe boxcutter_prometheus::postgres_exporter

# The Chef InSpec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec/resources/

describe port(9187) do
  it { should be_listening }
  its('processes') { should include 'postgres_export' }
end

describe processes('postgres_exporter') do
  its('entries') { should_not be_empty }
end

describe http('http://localhost:9187/metrics') do
  its('status') { should cmp 200 }
  its('body') { should match(/pg_database_connection_limit/) }
end
