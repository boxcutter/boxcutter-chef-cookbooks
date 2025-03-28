#
# Cookbook:: boxcutter_nvidia
# Recipe:: l4t
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
  # curl -fsSLO https://repo.download.nvidia.com/jetson/jetson-ota-public.asc
  #
  # List the key with `gpg --show-keys` like so:
  #
  # gpg --with-fingerprint --show-keys jetson-ota-public.asc
  #
  # On 2024-09-18 show-keys looked like this:
  #
  # pub   rsa4096 2019-05-09 [SC]
  #       3C6D 1FF3 100C 8C3A BB08  69C0 E654 3461 A999 6195
  # uid                      NVIDIA Corporation <linux-tegra-bugs@nvidia.com>
  # sub   rsa4096 2019-05-09 [E]
  # sub   rsa4096 2019-05-09 [S]
  #
  # Use the last 16 digits of the key signature as the key for
  # node.default['fb_apt']['keys']:
  #
  # E654 3461 A999 6195
  #
  # Then replace the GPG armored blocks with the following markers (content
  # remains the same:
  # -----BEGIN PGP PUBLIC KEY BLOCK-----
  # -----END PGP PUBLIC KEY BLOCK-----
  node.default['fb_apt']['keys']['E6543461A9996195'] = <<-EOS
-----BEGIN PGP PUBLIC KEY BLOCK-----

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
=/w3m
-----END PGP PUBLIC KEY BLOCK-----
  EOS

  # Omit signed-by and use apt-key to import the key
  node.default['fb_apt']['repos'] << 'deb https://repo.download.nvidia.com/jetson/common r36.3 main'
  node.default['fb_apt']['repos'] << 'deb https://repo.download.nvidia.com/jetson/t234 r36.3 main'
  node.default['fb_apt']['repos'] << 'deb https://repo.download.nvidia.com/jetson/ffmpeg r36.3 main'

  # /etc/modules-load.d/chef.conf
  node.default['fb_modprobe']['modules_to_load_on_boot'] += [
    'nvmap',
    'nvgpu',
    'pwm-fan',
    'ina3221',
    'nvidia-p2p',
  ]

  # /etc/modprobe.d/fb_modprobe.conf
  # node.default['fb_modprobe']['extra_entries'] += [
  #   '',
  # ]
end
