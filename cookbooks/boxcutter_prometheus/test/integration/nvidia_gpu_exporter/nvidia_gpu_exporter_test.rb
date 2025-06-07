# Chef InSpec test for recipe boxcutter_prometheus::nvidia_gpu_exporter

# The Chef InSpec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec/resources/

describe port(9835) do
  it { should be_listening }
  its('processes') { should include 'nvidia_gpu_expo' }
end

describe processes('nvidia_gpu_exporter') do
  its('entries') { should_not be_empty }
end

describe http('http://localhost:9835/metrics') do
  its('status') { should cmp 200 }
  its('body') { should match(/nvidia_smi_failed_scrapes_total/) }
end
