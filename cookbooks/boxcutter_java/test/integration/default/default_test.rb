# Chef InSpec test for recipe boxcutter_java::default

# The Chef InSpec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec/resources/

java_user = 'java'
java_group = 'java'
java_home = '/home/java'
sdkman_root = '/home/java/.sdkman'

describe user(java_user) do
  it { should exist }
  its('uid') { should eq 991 }
  its('gid') { should eq 991 }
  its('group') { should eq java_group }
  its('home') { should eq java_home }
  its('shell') { should eq '/bin/bash' }
end

sdk_version_command = \
  %{su --login #{java_user} --command "source \"#{sdkman_root}/bin/sdkman-init.sh\" && sdk version"}
describe command(sdk_version_command) do
  its('stdout') { should match(/SDKMAN/) }
end

sdk_current_java_command = \
  %{su --login #{java_user} --command "source \"#{sdkman_root}/bin/sdkman-init.sh\" && sdk current java"}
describe command(sdk_current_java_command) do
  its('stdout') { should match(/java version 11.0.24-tem/) }
end

sdk_list_java_command = \
  %{su --login #{java_user} --command "source \"#{sdkman_root}/bin/sdkman-init.sh\" && sdk list java"}
describe command(sdk_list_java_command) do
  its('stdout') { should match(/installed.*|.*11.0.24-tem/) }
end
