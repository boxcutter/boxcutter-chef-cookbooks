#
# Cookbook:: boxcutter_redis
# Recipe:: default
#
# Copyright:: 2025, Boxcutter
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

case node['platform']
when 'ubuntu'
  FB::Users.initialize_group(node, 'redis')
  node.default['fb_users']['users']['redis'] = {
    'gid' => 'redis',
    'home' => '/var/lib/redis',
    'shell' => '/usr/sbin/nologin',
    'action' => :add,
  }

  # https://redis.io/docs/latest/operate/oss_and_stack/install/archive/install-redis/install-redis-on-linux/
  node.default['fb_apt']['sources']['redis'] = {
    'key' => 'redis',
    'url' => 'https://packages.redis.io/deb',
    'suite' => node['lsb']['codename'],
    'components' => ['main'],
  }

  # curl -fsSLO https://packages.redis.io/gpg
  node.default['fb_apt']['keymap']['redis'] = <<~EOS
    -----BEGIN PGP PUBLIC KEY BLOCK-----

    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
    Oi5R+3n0UUbz020kbQ==
    =1K+h
    -----END PGP PUBLIC KEY BLOCK-----
  EOS

  package 'redis-server' do
    action :upgrade
  end

  directory '/var/lib/redis' do
    owner 'redis'
    group 'redis'
    mode '0750'
  end

  directory '/var/log/redis' do
    owner 'redis'
    group 'adm'
    mode '2750'
  end

  file '/var/log/redis/redis-server.log' do
    owner 'redis'
    group 'adm'
    mode '0660'
  end

  template '/etc/redis/redis.conf' do
    source 'redis.conf.erb'
    owner 'redis'
    group 'redis'
    mode '0640'
    notifies :restart, 'service[redis-server]'
  end

  service 'redis-server' do
    action [:enable, :start]
    only_if { node['boxcutter_redis']['enable'] }
  end

  service 'disable redis-server' do
    service_name 'redis-server'
    action [:stop, :disable]
    not_if { node['boxcutter_redis']['enable'] }
  end
when 'centos'
  # At the moment EPEL has Redis 6.x instead of 7.x. Until that changes,
  # just install the package and don't manage configuration
  package 'redis' do
    action :upgrade
  end

  service 'redis' do
    action [:enable, :start]
    only_if { node['boxcutter_redis']['enable'] }
  end

  service 'disable redis-server' do
    service_name 'redis'
    action [:stop, :disable]
    not_if { node['boxcutter_redis']['enable'] }
  end
end
