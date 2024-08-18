#
# Cookbook:: boxcutter_init
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

# SANITY-INDUCING HACK
# If we have never run before, run in debug mode. This ensures that for
# first run/bootstrapping issues we have lots of visibility.
if node.firstboot_any_phase?
  Chef::Log.info('Enabling debug log for first run')
  Chef::Log.level = :debug
end

# this should be first.
include_recipe 'boxcutter_init::site_settings'

if node.centos?
  # HERE: yum
  include_recipe 'fb_dnf'
  include_recipe 'fb_rpm'
end
if node.debian? || node.ubuntu?
  include_recipe 'fb_apt'
end
# HERE: chef_client
unless ['dokken', 'kitchen-test'].include?(node['hostname']) # in_kitchen?
  include_recipe 'boxcutter_chef::default'
end
if node.centos?
  include_recipe 'fb_e2fsprogs'
  include_recipe 'fb_util_linux'
end
# if node.systemd? && !node.container?
if node.systemd?
  include_recipe 'fb_systemd'
  include_recipe 'fb_timers'
end
# if node.macos?
#   include_recipe 'fb_launchd'
# end
include_recipe 'fb_nsswitch'
# HERE: ssh
include_recipe 'fb_ssh'
# include_recipe 'fb_less'
# if node.linux? && !node.embedded? && !node.container?
#   include_recipe 'fb_ethtool'
# end
# if node.centos?
#   include_recipe 'fb_ldconfig'
# end
# if node.linux? && !node.container?
#   if node.fedora?
#     include_recipe 'fb_grubby'
#   end
#   include_recipe 'fb_grub'
# end
# if node.centos?
#   include_recipe 'fb_dracut'
# end
# if node.centos? && !node.container?
#   include_recipe 'fb_storage'
# end
if !node.container?
  include_recipe 'fb_modprobe'
end
# include_recipe 'fb_securetty'
# include_recipe 'fb_hostname'
# include_recipe 'fb_hosts'
include_recipe 'fb_ethers'
# HERE: resolv
include_recipe 'fb_limits'
# include_recipe 'fb_hostconf'
include_recipe 'fb_sysctl'
# HERE: networking
#
onepassword_list = %w{
  hq0-rt01
}
if onepassword_list.include?(node['hostname'])
  include_recipe 'boxcutter_users::root'
end
include_recipe 'fb_users'
# if node.centos?
#   # We turn this off because the override causes intermittent failures in
#   # Travis when rsyslog is restarted
#   node.default['fb_syslog']['_enable_syslog_socket_override'] = false
# end
if !node.container?
  include_recipe 'fb_syslog'
end
# if node.linux? && !node.container?
#   include_recipe 'fb_hdparm'
#   include_recipe 'fb_sdparm'
#   include_recipe 'fb_nscd'
#   # hddtemp was removed from ubuntu 22.04 and Debian 12 due to lack of
#   # maintenance
#   # include_recipe 'fb_hddtemp'
# end
# include_recipe 'fb_postfix'
# HERE: nfs
include_recipe 'boxcutter_nfs::client'
# include_recipe 'fb_swap'
# WARNING!
# fb_fstab is one of the most powerful cookbooks in the facebook suite,
# but it requires some setup since it will take full ownership of /etc/fstab
if !node.container?
  include_recipe 'fb_fstab'
end
# include_recipe 'fb_mlocate'
include_recipe 'fb_logrotate'
# HERE: autofs
include_recipe 'fb_tmpclean'
include_recipe 'fb_sudo'
# HERE: ntp
if node.linux?
  include_recipe 'fb_chrony' unless node.ubuntu? && node['platform_version'].to_i == 22

  node.default['fb_ipset']['auto_cleanup'] = false
  include_recipe 'fb_ipset'
  include_recipe 'fb_iptables'
end
# if node.linux? && !node.container?
#   include_recipe 'fb_chrony'
#
#   if node.centos?
#     node.default['fb_ipset']['auto_cleanup'] = false
#     include_recipe 'fb_ebtables'
#     include_recipe 'fb_ipset'
#     include_recipe 'fb_iptables'
#     include_recipe 'fb_iproute'
#     include_recipe 'fb_ipset::cleanup'
#   end
# end
include_recipe 'fb_motd'
include_recipe 'fb_profile'

# if node.firstboot_tier?
#   include_recipe 'fb_init_sample::firstboot'
# end

# unless node.centos6?
#   include_recipe 'fb_apcupsd'
#   # Turn off dnsmasq as it doesn't play well with travis
#   node.default['fb_dnsmasq']['enable'] = false
#   if !node.container?
#     include_recipe 'fb_dnsmasq'
#   end
# end
# include_recipe 'fb_collectd'
# include_recipe 'fb_rsync::server'
# if node.centos?
#   include_recipe 'fb_sysstat'
# end
# if node.linux?
#   include_recipe 'fb_screen'
#   if !node.container?
#     include_recipe 'fb_stunnel'
#   end
# end

# we recommend you put this as late in the list as possible - it's one of the
# few places where APIs need to use another API directly... other cookbooks
# often want to setup cronjobs at runtime based on user attributes... they can
# do that in a ruby_block or provider if this is at the end of the 'base
# runlist'
include_recipe 'fb_cron'

fb_helpers_reboot 'process deferred reboots' do
  __fb_helpers_internal_allow_process_deferred true
  action :nothing
end

# We want this to run with the notifications at the very end of the run to
# handle reboot requests that happen any time during the run.
# ... but if we run this at the end and the run fails before then we'll drop
# the reboot on the floor. So we play games. We schedule, as early as possible,
# the scheduling. :)
whyrun_safe_ruby_block 'deferred reboot intermediate' do
  block {}
  notifies :process_deferred, 'fb_helpers_reboot[process deferred reboots]'
  action :nothing
end

# This will run very early, which adds a delayed notification to the
# intermediate block which won't happen until notifications are being processed
# at the end of the run. That will then fire a notification which will be added
# to the end of the notifications list, to schedule the reboot, so it should
# happen ~last
whyrun_safe_ruby_block 'Schedule process deferred reboots' do
  block {}
  notifies :run, 'whyrun_safe_ruby_block[deferred reboot intermediate]'
end
