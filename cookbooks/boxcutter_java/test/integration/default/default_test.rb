# Chef InSpec test for recipe boxcutter_java::default

# The Chef InSpec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec/resources/

java_user = 'boxcutter'
java_group = 'boxcutter'
java_home = '/home/boxcutter'
sdkman_root = '/home/boxcutter/.sdkman'

describe user(java_user) do
  it { should exist }
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
  its('stdout') { should match(/java version 17.0.12-tem/) }
end

sdk_list_java_command = \
  %{su --login #{java_user} --command "source \"#{sdkman_root}/bin/sdkman-init.sh\" && sdk list java"}
describe command(sdk_list_java_command) do
  its('stdout') { should match(/local only.*|.*17\.0\.12-tem/) }
  its('stdout') { should match(/local only.*|.*8\.0\.382-tem/) }
end

sdk_list_sbt_command = \
  %{su --login #{java_user} --command "source \"#{sdkman_root}/bin/sdkman-init.sh\" && sdk list sbt"}
describe command(sdk_list_sbt_command) do
  its('stdout') { should match(/> \* 1\.10\.1/) }
end
