#
# Cookbook:: boxcutter_couchdb
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

# couchdb:x:110:114:CouchDB Administrator,,,:/opt/couchdb:/bin/bash
node.default['fb_users']['users']['couchdb'] = {
  'gid' => 'couchdb',
  'comment' => 'CouchDB Administrator',
  'home' => '/opt/couchdb',
  'shell' => '/bin/bash',
  'action' => :add,
}
FB::Users.initialize_group(node, 'couchdb')

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
  # curl -fsSLO https://couchdb.apache.org/repo/keys.asc
  #
  # List the key with `gpg --show-keys` like so:
  #
  # gpg --with-fingerprint --show-keys keys.asc
  #
  # On 2024-10-28 show-keys looked like this:
  #
  # pub   rsa8192 2015-01-19 [SC]
  # 390E F70B B1EA 12B2 7739  6295 0EE6 2FB3 7A00 258D
  # uid                      The Apache Software Foundation (Package repository signing key) <root@apache.org>
  #
  # Use the last 16 digits of the key signature as the key for
  # node.default['fb_apt']['keys']:
  #
  # 0EE6 2FB3 7A00 258D
  #
  # Copy the key contents from above with:
  # -----BEGIN PGP PUBLIC KEY BLOCK-----
  # -----END PGP PUBLIC KEY BLOCK-----
  node.default['fb_apt']['keys']['0EE62FB37A00258D'] = <<-EOS
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG/MacGPG2 v2.0.22 (Darwin)
Comment: GPGTools - https://gpgtools.org

mQQNBFS9JYkBIAC/0ol2lpWq2l/fSkiNqZWaslxO6VgHITtd2C6mEXo/DnRPL7Rz
GfTbpUhzZmKFaUquJdq5Ed7qDYgJcbTJsSSJoWvbidl1peEjyrUFh9h1V+ow3ueK
+4VJwJCm4DtYPgqrJrSNW2nNRcx0XdwUCYC3YlIAa8vvVYniYB8OTv7BYZu7wKaX
POOlwl9KMQn4B5SEQm/E6u7+Wyg/I+gjq1yReFD4M4LUSuEDjTJLalJbO2zwW2wu
LQOeaT7TGqVef8tDVBwPbvV2+8FUE82M+f7wMIfmCzFNupf6ZmpwTmW46AqIgItw
1PxHH7BDxiKN9i65DPA097Cq9uLwRBUaZdUTT3G4DrkyecAnoEnshA1NxtErKuvj
9OXMXFnX/UsqKB1y9BN6+ERIkZJLMfGGRmbDxggJA3FzewfkYw0PBM6FkVRoDgJq
zpgzOQq8HBXojS3jMWKMvRNSwWAQ4frqcHz57Ml5ZUdJFtpA5TKwLkMvAFToIiA6
a20aMnPYLXrbYSVSK/vHSNgAqyNgi8b7ZPYmQnRGtp3wycMfNENs6aqVoKepLXJj
5W3Rudn2XJ1BCqv2wkLeTx6tG/R0222+J+wh+Zh8Ut+rsu8GVW9P7mEkJoB6+/8O
lyYeuLFh803cCllVR3k5pWN7ZU7ehY26V53c5HBtU5yjEcHVfiC2KGvew+tIWxK7
Iy/TAuPGGTo7/o6Si73Pq2UmqD3LLAta7K1xhoVQTxt/9TAM6lTObpvgBj5LHUZh
X/Gt+EohI/7wo1VvaDUh0iBWdJbYNqz5AeyFxvM1fCvThWHl7RHXfkiyOp2RL6bs
Gnqh30DeIzjcdh6nvFLAyuFwvRBguiu97ug+/lv7PJfjOtUUmz/V4tkvLBoLRY5c
nnPAQQOz7iSoatUpsdo2CCr4n9agfC7V+8vEsPU4RBqp3CXxz2RivZiBqwQOBV3V
777pZIZm+XByY1sKOESrbnc52mIXZ5p6LuXqWw8yiCDC6wsKfYWIDt7zAD2/QDu2
lwVbHpebbJChY10aqLg4wun0KkOeOhH3/GA7SH4cURcmnUsEUU5mS6cVCzl8Zfgk
MF82T3HbFArp23J85xNDAvsbo+LpYFFMYPE6tetkaWPY2ln92Oh/iFQT72boWgnm
XAtgIeJy4aNbwGKVygEtvqr+dLdzYarh4fq66pUArN6CK8ovgomSNeciaoJ02kVj
DTkSzCkfqE8b+bK6GT2W3fWZX4aFsaJMJu6yDmqsJc2rhpbSwydCLLXOW6ammT19
ojIGIyGujg1nNYqKr5rAh71MIU47PNZ93E/4eBIYJd3GwQFmczP3evVNqoYRC8RK
CS+uLcSkqRw6CzSLbp6e9K8Nrvpl2tbI61yvABEBAAG0UVRoZSBBcGFjaGUgU29m
dHdhcmUgRm91bmRhdGlvbiAoUGFja2FnZSByZXBvc2l0b3J5IHNpZ25pbmcga2V5
KSA8cm9vdEBhcGFjaGUub3JnPokENwQTAQoAIQUCVL0liQIbAwULCQgHAwUVCgkI
CwUWAgMBAAIeAQIXgAAKCRAO5i+zegAljejKH/0fFifmNa05Cv1iGZ8TkfEQieQZ
ETR/7W4t52vqVK8pw4ismtp/HkDdU1MU3HlESN3JX0t+OcbKHx95euNjq12ZeOn4
ifpCzse3fAoy/GCbfZOacxhhB9n1FbgqPAE+QAqvaZTz4Nx3KWfhRF64WCqbKI/A
oBLW/ZZZ/5UCJJY6vTliw+ErwH4LqExFopUL9WDoJpMb9RtQv2e+r00RAinLwP1Z
+o3DOxB776ub2oxCADIXL0in5uJWvGG3F5VNLFLa9mz63LyOtAtgcuc9bO/3hAq0
Fud5BXWUeRVj0YVjh/lfOlVXLyLUctboPIKjB+QvU1bFa8qmuWQltIh3Jrnaf4SC
dS+3ZWeXMAC83PPYNAClvRvtysJJWZnncdAUJWHJ7o6x6cXseUDbdK8XX7CTeCO2
uzmWsMKTrv+PBo8ZFznxAbFDJeyIG8woDJW8f41Wipf+Eb4w/Da/5C0ws4D1Ph22
C3lt9fCbsRgTIGmDNqX+QQgmDkYWuKSI1TDHbobIO95KVGT87H3n+77H/N3cBdt5
ayC9kYmO35WMdtaSwT4+8cS7cG5QtFH2KUzgQ5we9jDXpnnvkzY2qko8cTySGOHY
5IWVmm0A1qsuZZIUEXTiVQI/ZGp/QNfm9rI6Ajm8xCp2FBXzd1cfeRgpgxNmEHSc
9RIAg1mHfInTdcsnd7Awtne6/WTgnods4NCq+oZElhYdi0P+IMZgfqXY7QPsRDcH
6TmxyRC+0AQMSxFeXOxhVKxZXjX4Z+GdbT7OJDDuHPZNPKPLhtk9PYaCfBY/XZZk
kurjT2oROzJqzLAHNU8oj9zr88ra0OGk1vxkyYkTckacKH3zXRNxM0Pt/cHe4NAd
aanRsbNHwl2+e7VtZFC+0ND3bfKcsSYKFc0wud/KU/LYY0FHYpBZIR6Iu/lbAV24
rcJ3M3UA1fet/7J0KSlOc5lvmCGVWbfT4/tgxadG+SsxCBT0V5RDl0WsNquQV1sp
p7EPptv1Z3qkj1CIi4RHsa4hemUmOZ4RMQWyw/R6NSX16u6uNieqZ1j7fNQqHfpg
JFaFVTxeDFRiHUc4WUUXGov5FXLZkSXrEPAA3euVFSuhosSJuUhOVF8YLauCGmdp
DrDhLoq/pzCDdG+UZJPcJFm3M/xgwuxi/GF7LEaPOtbkHTWbdIwQvImS4dyUnxRI
BfKq5tGv25JfNOTmlcS3xucMHx5MgpxmNCisPRwPgT3EuPX/Gr+dUE+TsaFgPa4d
XGVUPb5A/e5bmhh4vWxBVmhhX3+8u6lkqMk3ysSdghlKD8uN+zxFUB/E0bN/EiDI
OwfrHL71avpTZwG/JP/5R1kJWdiVrTJo+HcfjPEmaS1kzgbAxptdo5WHCmExiQIc
BBABCgAGBQJUvS5GAAoJECsRil+hXzC59SUP/0AXwVkhX/4MsJsPZkwCzF3Fh7E/
BtTBGVeJrXtwb/NI+WZyMz6MF8eOX8oqKRVbHvpxsKxxZIss9GeuBjZMI5Hq/C0S
/ZSYV+HV3e90al81h5VA/n+ht+xsTFLotRgi0bCJDXm2tRwP/y6ilm8pGSV7vs0G
7URen7g7To0DaoTAS449OEgYxkJthNPEXYVrAPFgiHfMWJTgoSxZ5PKLcuDCutmK
yzP5s6xWCVACcBHmVXKZ6g8tWWwvaKYHZ9DmWEiz3Wy/5mVLNVBrOVxwWke1dT6R
7PVqw/vCYoPuzHmjJAOM+ysoOnkkSM/ImA7/DIXlkhK6afo/7ioLkfFIXqYJUwnQ
vwlw7rhcOTpDA62MdYR5D37AoQTZvDytOV9JvqWj9qima89eJCaMbjdNrmQggiEv
1US1pxHUgEqM0Zo2mDCA7tA64gjhoHVvwqdCKX/sKw7XAzeLX3l3GHbuW5JT+zcK
gsQ24W/sgi5zpKmlWkR8rtwRHdJyvZpLnQJUxsXfK9TuuwAKvEmOCup+IthaGmWq
LZxCypOGtUpFC9yDxUtEOe5KFJ5DWJ/fpwk9LDt5RRiro9wLMKksaZsi++dDDdBX
nxzxVcj7HXSLbpXTxo6ZhzzLHNFtDHYmhNhJDDPJIQO/lBr7/hIwmFfcBAuimMZI
a7iaf/ZM3apksz3p
=Kn6W
-----END PGP PUBLIC KEY BLOCK-----
  EOS

  # Omit signed-by and use apt-key to import the key
  node.default['fb_apt']['repos'] \
    << "deb https://apache.jfrog.io/artifactory/couchdb-deb/ #{node['lsb']['codename']} main"
when 'centos'
  # https://couchdb.apache.org/repo/couchdb.repo
  node.default['fb_yum_repos']['repos']['couchdb'] = {
    'repos' => {
      'couchdb' => {
        'name' => 'couchdb',
        'baseurl' => 'https://apache.jfrog.io/artifactory/couchdb-rpm/el$releasever/$basearch/',
        'gpgcheck' => true,
        'repo_gpgcheck' => true,
        'gpgkey' => 'https://couchdb.apache.org/repo/keys.asc https://couchdb.apache.org/repo/rpm-package-key.asc',
        'type' => 'rpm',
      },
    },
  }

  # On CentOS9 the EPEL9 repo depends on the CRB repo
  execute 'enable crb' do
    only_if { node.centos9? }
    not_if 'dnf repolist | grep crb'
    command 'dnf config-manager --set-enabled crb'
  end

  if node.centos9?
    package 'epel-release' do
      action :upgrade
    end

    package 'epel-next-release' do
      action :upgrade
    end
  end
end

# https://github.com/apache/couchdb-pkg/blob/main/debian/README.Debian
# Couchdb will return an error when run non-interactively because the config
# script won't run. Disable this configuration so the package install doesn't
# return an error.
execute 'disable couchdb configuration' do
  command 'echo "couchdb couchdb/mode select none" | debconf-set-selections'
  action :nothing
end

package 'couchdb' do
  action :upgrade
  notifies :run, 'execute[disable couchdb configuration]', :before
end

boxcutter_couchdb 'configure'

# automat@sfo2-ubuntu-server-2204:/etc/systemd/system/multi-user.target.wants$ cat couchdb.service
# [Unit]
# Description=Apache CouchDB
# Wants=network-online.target
# After=network-online.target
#
# [Service]
# EnvironmentFile=-/etc/default/couchdb
# RuntimeDirectory=couchdb
# User=couchdb
# Group=couchdb
# ExecStart=/opt/couchdb/bin/couchdb
# Restart=always
# LimitNOFILE=65536
#
# [Install]
# WantedBy=multi-user.target
