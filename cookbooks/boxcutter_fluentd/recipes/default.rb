#
# Cookbook:: boxcutter_fluentd
# Recipe:: default
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

node.default['fb_users']['users']['_fluentd'] = {
  'gid' => '_fluentd',
  'action' => :add,
}
FB::Users.initialize_group(node, '_fluentd')

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
  # curl -fsSLO https://packages.treasuredata.com/GPG-KEY-td-agent
  #
  # List the key with `gpg --show-keys` like so:
  #
  # gpg --with-fingerprint --show-keys GPG-KEY-td-agent
  #
  # In 2024-11-09 show-keys looked like this:
  #
  # pub   rsa4096 2016-12-27 [SC]
  #       BEE6 8228 9B22 17F4 5AF4  CC3F 901F 9177 AB97 ACBE
  # uid                      Treasure Data, Inc (Treasure Agent Official Signing key) <support@treasure-data.com>
  # sub   rsa4096 2016-12-27 [E]
  #
  # Use the last 16 digits of the key signature as the key for
  # node.default['fb_apt']['keys']:
  #
  # 901F 9177 AB97 ACBE
  #
  # Then replace the GPG armored blocks with the following markers (content
  # remains the same):
  # -----BEGIN PGP PUBLIC KEY BLOCK-----
  # -----END PGP PUBLIC KEY BLOCK-----
  case node['kernel']['machine']
  when 'aarch64', 'arm64'
    node.default['fb_apt']['repos'] <<
      "deb [arch=arm64] https://packages.treasuredata.com/lts/5/ubuntu/#{node['lsb']['codename']}/ #{node['lsb']['codename']} contrib"
  when 'x86_64', 'amd64'
    node.default['fb_apt']['repos'] <<
      "deb [arch=arm64] https://packages.treasuredata.com/lts/5/ubuntu/#{node['lsb']['codename']}/ #{node['lsb']['codename']} contrib"
  end

  node.default['fb_apt']['keys']['901F9177AB97ACBE'] = <<~EOS
    -----BEGIN PGP PUBLIC KEY BLOCK-----
    Version: GnuPG v2

    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
    5Ow=
    =Me4L
    -----END PGP PUBLIC KEY BLOCK-----
  EOS
when 'centos'
  node.default['fb_yum_repos']['repos']['fluent-package-lts.repo'] = {
    'repos' => {
      'fluent-package-lts' => {
        'name' => 'Fluentd Project',
        'baseurl' => 'https://packages.treasuredata.com/lts/5/redhat/$releasever/$basearch',
        'gpgcheck' => true,
        'gpgkey' => ['https://packages.treasuredata.com/GPG-KEY-td-agent', ' https://packages.treasuredata.com/GPG-KEY-fluent-package'],
      },
    },
  }
end

package 'fluent-package' do
  action :upgrade
end

# /etc/fluent/fluentd.conf

service 'fluentd' do
  only_if { node['boxcutter_docker']['enable'] }
  action [:enable, :start]
end

service 'disable fluentd' do
  service_name 'fluentd'
  not_if { node['boxcutter_docker']['enable'] }
  action [:stop, :disable]
end
