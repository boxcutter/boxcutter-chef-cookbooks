#
# Cookbook:: boxcutter_fluent
# Recipe:: fluent_bit
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

case node['platform']
when 'ubuntu'
  # For now, continue to publish keys installable by apt-key, so we don't have
  # to change fb_apt yet. apt-key is not going away until after Ubuntu 22.04.
  # Hopefully Facebook will accommodate fb_apt to work without apt-key so we
  # don't have to do it.
  #
  # To get the information needed from a gpg key, download it to a temporary
  # ubuntu install:
  #
  # curl -fsSLO https://packages.fluentbit.io/fluentbit.key
  #
  # List the key with `gpg --show-keys` like so:
  #
  # gpg --with-fingerprint --show-keys fluentbit.key
  #
  # On 2024-11-27 show-keys looked like this:
  #
  # pub   rsa4096 2022-02-07 [SC]
  #       C3C0 A285 34B9 293E AF51  FABD 9F9D DC08 3888 C1CD
  # uid                      Fluentbit releases (Releases signing key) <releases@fluentbit.io>
  # sub   rsa4096 2022-02-07 [E]
  #
  # Use the last 16 digits of the key signature as the key for
  # node.default['fb_apt']['keys']:
  #
  # 9F9D DC08 3888 C1CD
  #
  # To dump the key contents, run:
  #
  # cat fluentbit.key
  #
  # Then replace the GPG armored blocks with the following markers (content
  # remains the same:
  # -----BEGIN PGP PUBLIC KEY BLOCK-----
  # -----END PGP PUBLIC KEY BLOCK-----
  node.default['fb_apt']['keys']['9F9DDC083888C1CD'] = <<-EOS
-----BEGIN PGP PUBLIC KEY BLOCK-----

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
rLDtY1tzWLCr3tkD306RQnRho29+PH5w+5qRNPA=
=LXe5
-----END PGP PUBLIC KEY BLOCK-----
EOS

  # Omit signed-by and use apt-key to import the key
  # node.default['fb_apt']['repos'] ||= [] # Ensure it's an Array
  node.default['fb_apt']['repos'] << \
    "deb https://packages.fluentbit.io/ubuntu/#{node['lsb']['codename']} #{node['lsb']['codename']} main"
when 'centos'
  node.default['fb_yum_repos']['repos']['fluent-bit'] = {
    'repos' => {
      'fluent-bit' => {
        'name' => 'Fluent Bit',
        'baseurl' => 'https://packages.fluentbit.io/centos/$releasever/',
        'gpgcheck' => true,
        'repo_gpgcheck' => true,
        'gpgkey' => 'https://packages.fluentbit.io/fluentbit.key',
        'type' => 'rpm',
      },
    },
  }
end

package 'fluent-bit' do
  action :upgrade
end

%w{
  /etc/fluent-bit/fluent-bit.conf
  /etc/fluent-bit/parsers.conf
  /etc/fluent-bit/plugins.conf
}.each do |path|
  file "remove legacy fluent-bit config #{path}" do
    path path
    action :delete
  end
end

fb_systemd_override 'fluent-bit' do
  unit_name 'fluent-bit.service'
  content(
    {
      'Service' => {
        # Empty record is required! It tells systemd to clean existing
        # values, as it appends values from drop ins.
        'ExecStart' => ['', '/opt/fluent-bit/bin/fluent-bit -c /etc/fluent-bit/fluent-bit.yaml'],
      },
    },
  )
end

execute 'check fluent-bit config' do
  command '/opt/fluent-bit/bin/fluent-bit --dry-run --config=/etc/fluent-bit/fluent-bit.yaml'
  action :nothing
end

template '/etc/fluent-bit/fluent-bit.yaml' do
  owner node.root_user
  group node.root_group
  mode '0644'
  notifies :restart, 'service[fluent-bit]'
  notifies :run, 'execute[check fluent-bit config]', :immediately
end

service 'fluent-bit' do
  action [:enable, :start]
  only_if { node['boxcutter_fluent']['fluent_bit']['enable'] }
end

service 'disable fluent-bit' do
  service_name 'fluent-bit'
  action [:stop, :disable]
  not_if { node['boxcutter_fluent']['fluent_bit']['enable'] }
end
