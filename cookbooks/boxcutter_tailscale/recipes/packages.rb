#
# Cookbook:: boxcutter_tailscale
# Recipe:: packages
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
  # curl -fsSLO https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg
  #
  # List the key with `gpg --show-keys` like so:
  #
  # gpg --with-fingerprint --show-keys jammy.noarmor.gpg
  #
  # On 2023-11-05 show-keys looked like this:
  #
  # pub   rsa4096 2020-02-25 [SC]
  #       2596 A99E AAB3 3821 893C  0A79 458C A832 957F 5868
  # uid                      Tailscale Inc. (Package repository signing key) <info@tailscale.com>
  #   sub   rsa4096 2020-02-25 [E]
  #
  # Use the last 16 digits of the key signature as the key for
  # node.default['fb_apt']['keys']:
  #
  # 458C A832 957F 5868
  #
  # To dump the key contents, run:
  #
  # gpg --enarmor < jammy.noarmor.gpg > foo.txt
  #
  # Then replace the GPG armored blocks with the following markers (content
  # remains the same:
  # -----BEGIN PGP PUBLIC KEY BLOCK-----
  # -----END PGP PUBLIC KEY BLOCK-----
  node.default['fb_apt']['keys']['458CA832957F5868'] = <<-EOS
-----BEGIN PGP PUBLIC KEY BLOCK-----

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
=AIVM
-----END PGP PUBLIC KEY BLOCK-----
  EOS

  # Omit signed-by and use apt-key to import the key
  node.default['fb_apt']['repos'] << "deb https://pkgs.tailscale.com/stable/ubuntu #{node['lsb']['codename']} main"
when 'centos'
  node.default['fb_yum_repos']['repos']['tailscale'] = {
    'repos' => {
      'tailscale' => {
        'name' => 'Tailscale stable',
        'baseurl' => "https://pkgs.tailscale.com/stable/centos/#{node['platform_version']}/$basearch",
        'gpgcheck' => true,
        'repo_gpgcheck' => true,
        'gpgkey' => 'https://pkgs.tailscale.com/stable/centos/9/repo.gpg',
        'type' => 'rpm',
      },
    },
  }
end

package 'tailscale' do
  action :upgrade
end
