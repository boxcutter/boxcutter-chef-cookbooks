# Chef InSpec test for recipe boxcutter_redis::default

# The Chef InSpec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec/resources/

package_name = case os.family
               when 'debian'
                 'redis-server'
               when 'redhat', 'fedora', 'amazon'
                 'redis'
               else
                 'redis-server' # reasonable default
               end

service_name = package_name

describe package(package_name) do
  it { should be_installed }
end

describe service(service_name) do
  it { should be_enabled }
  it { should be_running }
end

describe port(6379) do
  it { should be_listening }
  its('protocols') { should include 'tcp' }
end

describe processes('redis-server') do
  its('entries.length') { should be > 0 }
  its('users') { should include 'redis' }
end

describe command('redis-server --version') do
  its('stdout') { should match(/Redis server v=\d+\.\d+\.\d+/) }
  its('exit_status') { should eq 0 }
end

describe command('redis-server') do
  it { should exist }
end

describe command('redis-cli ping') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match (/PONG/) }
end
