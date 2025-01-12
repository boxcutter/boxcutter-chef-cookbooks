#
# Cookbook:: boxcutter_ros
# Recipe:: gazebo
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
  # For now, continue to publish keys installable by apt-key, so we don't have
  # to change fb_apt yet. apt-key is not going away until after Ubuntu 22.04.
  # Hopefully Facebook will accommodate fb_apt to work without apt-key so we
  # don't have to do it.
  #
  # To get the information needed from a gpg key, download it to a temporary
  # ubuntu install:
  #
  # curl -fsSLO https://packages.osrfoundation.org/gazebo.gpg
  #
  # List the key with `gpg --show-keys` like so:
  #
  # gpg --with-fingerprint --show-keys gazebo.gpg
  #
  # On 2025-01-02 show-keys looked like this:
  #
  # pub   rsa2048 2015-04-01 [SC]
  #       D248 6D2D D83D B692 72AF  E988 6717 0598 AF24 9743
  # uid                      OSRF Repository (OSRF Repository GPG key) <osrfbuild@osrfoundation.org>
  # sub   rsa2048 2015-04-01 [E]
  #
  # Use the last 16 digits of the key signature as the key for
  # node.default['fb_apt']['keys']:
  #
  # 6717 0598 AF24 9743
  #
  # To dump the key contents, run:
  #
  # gpg --enarmor < gazebo.gpg > gazebo.txt
  #
  # Then replace the GPG armored blocks with the following markers (content
  # remains the same:
  # -----BEGIN PGP PUBLIC KEY BLOCK-----
  # -----END PGP PUBLIC KEY BLOCK-----
  node.default['fb_apt']['keys']['67170598AF249743'] = <<-EOS
-----BEGIN PGP PUBLIC KEY BLOCK-----

mQENBFUcKaEBCAD1ajXaWLnow3pZEv44Lypt6s5jAh1rYPN6zpaFZWdkzpwTdYU1
Rpw/0hPzIoiyOPNwCti4E3+dSrv1ogEBu85P2XSy67RnabxF4/z7mPG/++u0EQav
CwfrsN8OpJTtTxk+nKIhVwpAtob+KOLATerTPETrdrKh7qJ/FE8cw/XXbknjwywf
R8uJqaKTu7mWNrTFaS3P5GZF5ss+ztf0EHcyYFMvzEVnSiOGBBL9pw91P1qpggBa
lKL1Ilmf6zZBPihORJ/iTH5qMCAPDdR5BaxxEUHgz+pg+RkLKd2ENEaO+SCDVRhP
yNdkYHpuIslyMHfXrh4y5nHclJ+bNXKXDcudABEBAAG0R09TUkYgUmVwb3NpdG9y
eSAoT1NSRiBSZXBvc2l0b3J5IEdQRyBrZXkpIDxvc3JmYnVpbGRAb3NyZm91bmRh
dGlvbi5vcmc+iQE4BBMBAgAiBQJVHCmhAhsDBgsJCAcDAgYVCAIJCgsEFgIDAQIe
AQIXgAAKCRBnFwWYrySXQ/D4CACVnSdHT/1dEkOrYkCnaFLNBrG2tJdBrbIZOxKy
+xV0yGniqsQFAxLESoy+ygaiKdTnAFlA24ozoNY8ur+oKMFt6CrUY01ItTq/WMA1
iper0TO935SpDzNIPjPnD2WUSXShISWP0bFg64g0aAD1S7Yg/v7/eOmMSoeMav0T
h8KOo6yhJuhgGp3lHKAKLppH94b77d8JYqGeP03Gv6gcaqNojyKccdXrKTugZui5
+7V/cOJTo9XqzXjkpfwp24jR8FlKI7EWqCVqtRAXHeqRgo3OaKmuoKLcJ4/8BjSU
+ppmJtEstSaL+qw49P/GQHwUkCHlx1mV5dSdVFLBPreli1ChuQENBFUcKaEBCAC7
ZgTdYubw1sU/4A6+NvW/poBfh2DDOeh3uHJc0y235JFjr+tC1AwouaxLOUm8FE9k
7qzwnyXbeklmXAHxw6wXZdE4PEYA/sgBYhTQy+s4PHlI6TGhwgcROkJKlW4Lld+W
IJ/fzW93DXyhEkV3AAhkrVcOLOgCPdpK5EXxJ3p6dCOKC5Vjyz1PxTNcRaLpp9w6
J0hLIXmmoCN4aoYSXWtL/C9J+B5Cr+HHgrmFsGNrHmmVv1gMXLcVzw5p3Z4d8SuT
g9a1CemSE5bFIoOHKEQRwv/CGpoviAr+T3za3dPFTcSMOoJuYvoheTJ6fhf2sj74
bp2Fwi4L7am/asfa7xWVABEBAAGJAR8EGAECAAkFAlUcKaECGwwACgkQZxcFmK8k
l0OX9Af+IrzUChXf6H0nZZY77gcjwFgVChRX1RLzHTTHum4WNKGP9Sw1aGdHpmdt
LhypQImxdT2yhCPEyB8EQxhgPHjqZ6UUMeYMw5rAvrcb3/ercy5pG7O8Z+Bea6hu
TAXquJ1tsFessZwMS3RUXp/gtZCHbESR7PeBlZJWBWxG/lOmX7Z4fa88dWRU0Pl/
nfns7v6eb57HXbf0teCitRRsJwCMhYbHj2m1slZHMjhEc6kv2bgPmAFb04bcyEAP
BAo3BKu2XUVqE1t7Q2EfsItL/0FpfDY6zGKM6NIi+C40CsRl4W0o6egUhiDqsMYX
9Su5aZdCoxMhzy5QxS3sXcpNAWH2gw==
=YM5F
-----END PGP PUBLIC KEY BLOCK-----
  EOS

  # Omit signed-by and use apt-key to import the key
  node.default['fb_apt']['repos'] << \
    "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable #{node['lsb']['codename']} main"
when 'centos'
  raise 'Unsupported platform'
end

package 'gz-harmonic' do
  action :upgrade
end
