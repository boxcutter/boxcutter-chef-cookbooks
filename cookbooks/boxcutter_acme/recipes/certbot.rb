#
# Cookbook:: boxcutter_acme
# Recipe:: certbot
#
# Copyright:: 2024-present, Taylor.dev, LLC
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

include_recipe 'boxcutter_python::system'

%w{
  /opt/certbot
  /opt/certbot/bin
}.each do |dir|
  directory dir do
    owner 'root'
    group 'root'
    mode '0700'
  end
end

boxcutter_python_virtualenv '/opt/certbot/venv'

boxcutter_python_pip 'certbot' do
  virtualenv '/opt/certbot/venv'
  action :upgrade
end

# Only bother configuring cloudflare plugins if we're provided an api token
if node.exist?('boxcutter_acme', 'certbot', 'cloudflare_api_token') ||
  node.run_state.key?('boxcutter_acme') \
  && node.run_state['boxcutter_acme'].key?('certbot') \
  && node.run_state['boxcutter_acme']['certbot'].key?('cloudflare_api_token')

  boxcutter_python_pip 'certbot-dns-cloudflare' do
    virtualenv '/opt/certbot/venv'
    action :upgrade
  end

  cloudflare_api_token = node['boxcutter_acme']['certbot']['cloudflare_api_token']
  if node.run_state.key?('boxcutter_acme') \
    && node.run_state['boxcutter_acme'].key?('certbot') \
    && node.run_state['boxcutter_acme']['certbot'].key?('cloudflare_api_token')
    cloudflare_api_token = node.run_state['boxcutter_acme']['certbot']['cloudflare_api_token']
  end

  template '/etc/chef/cloudflare.ini' do
    source 'cloudflare.ini.erb'
    owner 'root'
    group 'root'
    mode '0400'
    variables(
      :cloudflare_api_token => cloudflare_api_token,
      )
  end
end

node.default['boxcutter_acme']['certbot']['config'].each do |name, config|
  execute "#{name} obtain certificate" do
    command config['renew_script_path']
    action :nothing
  end

  template config['renew_script_path'] do
    source 'certbot_renew.sh.erb'
    owner 'root'
    group 'root'
    mode '0700'
    variables(
      :certbot_bin => config['certbot_bin'],
      :domains => Boxcutter::Acme.to_bash_array(config['domains']),
      :email => config['email'],
      :cloudflare_ini => config['cloudflare_ini'],
      :extra_args => config['extra_args'],
    )
    notifies :run, "execute[#{name} obtain certificate]", :immediately
  end

  node.default['fb_timers']['jobs'][name] = {
    'calendar' => FB::Systemd::Calendar.every.weekday,
    'command' => config['renew_script_path'],
    'accuracy' => '1h',
    'splay' => '0.5h',
  }
end
