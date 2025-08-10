#
# Cookbook:: boxcutter_site_settings
# Recipe:: default
#
# Copyright:: 2023, Boxcutter
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

include_recipe '::remap_users'

puts "MISCHA: node['boxcutter_config']['tier] = #{node['boxcutter_config']['tier']}"
node.default['fb_users']['user_defaults']['gid'] = 'boxcutter'

if node.ubuntu?
  # https://wiki.debian.org/UnattendedUpgrades
  # Enable the update/upgrade script (0=disable)
  node.default['fb_apt']['config']['APT::Periodic::Enable'] = '0'
  # Do "apt-get update" automatically every n-days (0=disable)
  node.default['fb_apt']['config']['APT::Periodic::Update-Package-Lists'] = '0'
  # Do "apt-get upgrade --download-only" every n-days (0=disable)
  node.default['fb_apt']['config']['APT::Periodic::Download-Upgradeable-Packages'] = '0'
  # Run the "unattended-upgrade" security upgrade script every n-days (0=disabled)
  # Requires the package "unattended-upgrades" and will write a log in /var/log/unattended-upgrades
  node.default['fb_apt']['config']['APT::Periodic::Unattended-Upgrade'] = '0'
  # Do "apt-get autoclean" every n-days (0=disable)
  node.default['fb_apt']['config']['APT::Periodic::AutocleanInterval'] = '0'

  %w{
    apt-daily.timer
    apt-daily.service
    apt-daily-upgrade.timer
    apt-daily-upgrade.service
  }.each do |unit|
    service unit do
      action [:stop, :disable]
    end
  end

  package 'snapd' do
    action :upgrade
  end

  service 'snapd' do
    action [:enable, :start]
  end

  # Some snap applications will refuse to start if the snap daemon is disabled
  # so instead put auto-updates on pause
  # https://snapcraft.io/docs/managing-updates
  execute 'disable snap auto-updates' do
    command 'snap refresh --hold'
    not_if 'snap get system refresh.hold | grep -w forever'
    only_if { ::File.exist?('/usr/bin/snap') }
    action :run
  end

  cookbook_file '/etc/update-manager/release-upgrades' do
    owner node.root_user
    group node.root_group
    mode '0644'
    only_if { Dir.exist?('/etc/update-manager') }
  end
end

include_recipe 'boxcutter_users'

include_recipe '::ssh'

if node.ubuntu?
  # us.archive.ubuntu.com and the core Ubuntu repositories do not have ARM
  # binaries. ARM binaries are only on ports.ubuntu.com
  node.default['fb_apt']['mirror'] = if node['kernel']['machine'] == 'aarch64'
                                       'http://ports.ubuntu.com/ubuntu-ports'
                                     else
                                       'http://archive.ubuntu.com/ubuntu'
                                     end

  node.default['fb_apt']['security_mirror'] = if node['kernel']['machine'] == 'aarch64'
                                                'http://ports.ubuntu.com/ubuntu-ports'
                                              else
                                                'http://security.ubuntu.com/ubuntu'
                                              end

  # Timesync is masked by default in Ubuntu now
  if node.systemd?
    node.default['fb_systemd']['timesyncd']['enable'] = false
  end

  # DigitalOcean
  if digital_ocean?
    puts 'MISCHA on DigitalOcean'

    node.default['fb_apt']['want_backports'] = true
    node.default['fb_apt']['want_non_free'] = true
    node.default['fb_apt']['mirror'] = 'http://mirrors.digitalocean.com/ubuntu/'
    node.default['fb_apt']['security_mirror'] = 'http://security.ubuntu.com/ubuntu'

    # Disable automatic updates
    {
      'APT::Periodic::Update-Package-Lists' => '0',
      'APT::Periodic::Download-Upgradeable-Packages' => '0',
      'APT::Periodic::AutocleanInterval' => '0',
      'APT::Periodic::Unattended-Upgrade' => '0',
    }.each do |key, value|
      node.default['fb_apt']['config'][key] = value
    end
  end
end

include_recipe '::dnf'

node.default['fb_ssh']['sshd_config']['X11Forwarding'] = true

if node.linux?
  include_recipe '::users'
end

if node['boxcutter_config']['tier'] && node['boxcutter_config']['tier'] == 'workstation' ||
  node['boxcutter_config']['tier'] && node['boxcutter_config']['tier'] == 'builder' &&
  node['kernel']['machine'] == 'aarch64'
  node.default['fb_systemd']['default_target'] = 'graphical.target'
end
