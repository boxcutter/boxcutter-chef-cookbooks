# Chef InSpec test for recipe boxcutter_sonatype::default

# The Chef InSpec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec/resources/

describe file('/opt/sonatype/nexus/bin/nexus.vmoptions') do
  it { should exist }
  it { should be_file }

  its('content') { should match(%r{^-Dkaraf\.data=/var/lib/nexus/nexus-data$}m) }
  its('content') { should match(%r{^-Dkaraf\.data=/var/lib/nexus/nexus-data/log$}m) }
  its('content') { should match(%r{^-Dkaraf\.data=/var/lib/nexus/nexus-data/log/jvm\.log$}m) }
  its('content') { should match(%r{^-Dkaraf\.data=/var/lib/nexus/nexus-data/tmp$}m) }
end
