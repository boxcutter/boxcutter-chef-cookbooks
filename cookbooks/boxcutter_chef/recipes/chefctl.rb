#
# Cookbook:: boxcutter_chef
# Recipe:: chefctl
#
# Copyright:: 2024, Boxcutter
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

cookbook_file '/usr/local/sbin/chefctl.rb' do
  source 'chefctl/chefctl.rb'
  owner 'root'
  group 'root'
  mode '0755'
end

cookbook_file '/etc/chefctl-config.rb' do
  source 'chefctl/chefctl-config.rb'
  owner 'root'
  group 'root'
  mode '0644'
end

cookbook_file '/etc/chef/chefctl_hooks.rb' do
  source 'chefctl/chefctl_hooks.rb'
  owner 'root'
  group 'root'
  mode '0644'
end

link '/usr/local/sbin/chefctl' do
  to '/usr/local/sbin/chefctl.rb'
end

link '/usr/local/sbin/stop_chef_temporarily' do
  only_if { ::File.symlink?('/usr/local/sbin/stop_chef_temporarily') }
  action :delete
end

cookbook_file '/usr/local/sbin/taste-untester' do
  source 'taste-tester/taste-untester'
  owner 'root'
  group 'root'
  mode '0755'
end

cookbook_file '/usr/local/sbin/stop_chef_temporarily' do
  source 'chefctl/stop_chef_temporarily'
  owner 'root'
  group 'root'
  mode '0755'
end

confdir = '/etc/chef'

# {
#   'chef' => {
#     'time' => '*/15 * * * *',
#     'command' => '/usr/bin/test -f /var/chef/cron.default.override -o ' +
#       "-f #{confdir}/test_timestamp || /usr/local/sbin/chefctl -q &>/dev/null",
#   },
#   'taste-untester' => {
#     'time' => '*/5 * * * *',
#     'command' => '/usr/local/sbin/taste-untester &>/dev/null',
#   },
#   'remove override files' => {
#     'time' => '*/5 * * * *',
#     'command' => '/usr/bin/find /var/chef/ -maxdepth 1 ' +
#       '-name cron.default.override -mmin +60 -exec /bin/rm -f {} \; &>/dev/null',
#   },
#   # keep two weeks of chef run logs
#   'cleanup chef logs' => {
#     'time' => '1 1 * * *',
#     'command' => '/usr/bin/find /var/log/chef -maxdepth 1 ' +
#       '-name chef.2* -mtime +14 -exec /bin/rm -f {} \; &>/dev/null',
#   },
# }.each do |name, job|
#   node.default['fb_cron']['jobs'][name] = job
# end

node.default['fb_timers']['jobs']['chef'] = {
  'calendar' => FB::Systemd::Calendar.every(15).minutes,
  'command' => '/usr/bin/test -f /var/chef/cron.default.override -o ' +
    "-f #{confdir}/test_timestamp || /usr/local/sbin/chefctl -q &>/dev/null",
}
node.default['fb_timers']['jobs']['taste-untester'] = {
  'calendar' => FB::Systemd::Calendar.every(5).minutes,
  'command' => '/usr/local/sbin/taste-untester &>/dev/null',
}
node.default['fb_timers']['jobs']['remove_override_files'] = {
  'calendar' => FB::Systemd::Calendar.every(5).minutes,
  'command' => '/usr/bin/find /var/chef/ -maxdepth 1 ' +
    '-name cron.default.override -mmin +60 -exec /bin/rm -f {} \; &>/dev/null',
}
node.default['fb_timers']['jobs']['cleanup_chef_logs'] = {
  'calendar' => '*-*-* 01:01:00',
  'command' => '/usr/bin/find /var/log/chef -maxdepth 1 ' +
    '-name chef.2* -mtime +14 -exec /bin/rm -f {} \; &>/dev/null',
}

