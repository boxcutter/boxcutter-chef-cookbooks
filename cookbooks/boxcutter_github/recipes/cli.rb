#
# Cookbook:: boxcutter_github
# Recipe:: cli
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

# https://github.com/cli/cli/blob/trunk/docs/install_linux.md
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
  # curl -fsSLO https://cli.github.com/packages/githubcli-archive-keyring.gpg
  #
  # List the key with `gpg --show-keys` like so:
  #
  # gpg --with-fingerprint --show-keys githubcli-archive-keyring.gpg
  #
  # In 2024-09-12 show keys looked like this:
  #
  # pub   rsa4096 2022-09-06 [SC] [expires: 2026-09-05]
  #       2C61 0620 1985 B60E 6C7A  C873 23F3 D4EA 7571 6059
  # uid                      GitHub CLI <opensource+cli@github.com>
  # sub   rsa4096 2022-09-06 [E] [expires: 2026-09-05]
  #
  # Use the last 16 digits of the key signature as the key for
  # node.default['fb_apt']['keys']:
  #
  # 23F3 D4EA 7571 6059
  #
  # To dump the key contents, run:
  #
  # gpg --enarmor < githubcli-archive-keyring.gpg > foo.txt
  #
  # Then replace the GPG armored blocks with the following markers (content
  # remains the same:
  # -----BEGIN PGP PUBLIC KEY BLOCK-----
  # -----END PGP PUBLIC KEY BLOCK-----
  node.default['fb_apt']['keys']['23F3D4EA75716059'] = <<-eos
-----BEGIN PGP PUBLIC KEY BLOCK-----

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
ADUE8jV+eCAWuR9uIl4=
=qpKU
-----END PGP PUBLIC KEY BLOCK-----
  eos

  # Omit signed-by and use apt-key to import the key
  case node['kernel']['machine']
  when 'x86_64', 'amd64'
    node.default['fb_apt']['repos'] << 'deb [arch=amd64] https://cli.github.com/packages stable main'
  when 'aarch64', 'arm64'
    node.default['fb_apt']['repos'] << 'deb [arch=arm64] https://cli.github.com/packages stable main'
  end
when 'centos'
  node.default['fb_yum_repos']['repos']['gh_cli'] = {
    'repos' => {
      'gh-cli' => {
        'name' => 'packages for the GitHub CLI',
        'baseurl' => 'https://cli.github.com/packages/rpm',
        'enabled' => 1,
        'gpgkey' => 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x23F3D4EA75716059',
      },
    },
  }
  # puts "MISCHA: gh-cli #{node['fb_yum_repos']['repos']}"
end

package 'gh' do
  action :upgrade
end
