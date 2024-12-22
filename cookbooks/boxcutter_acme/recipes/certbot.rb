#
# Cookbook:: boxcutter_acme
# Recipe:: certbot
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

package ['python3', 'python3-venv'] do
  action :upgrade
end

directory '/opt/certbot' do
  owner node.root_user
  group node.root_group
  mode '0755'
end

execute 'create certbot virtualenv' do
  command 'python3 -m venv /opt/certbot/venv'
  creates '/opt/certbot/venv/bin/python'
end

%w{
  certbot
  certbot-dns-cloudflare
}.each do |pkg|
  execute "install #{pkg} python package" do
    command "/opt/certbot/venv/bin/python -m pip install #{pkg}"
    not_if "/opt/certbot/venv/bin/python -m pip list installed | grep ^#{pkg}"
  end

  execute "update #{pkg} python package" do
    command "/opt/certbot/venv/bin/python -m pip install --upgrade #{pkg}"
    only_if "/opt/certbot/venv/bin/python -m pip list --outdated | grep ^#{pkg}"
  end
end
