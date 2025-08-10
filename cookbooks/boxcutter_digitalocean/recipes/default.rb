#
# Cookbook:: boxcutter_digitalocean
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

return unless digital_ocean?

# Droplet Agent - agent required to be installed to have droplet console
# in web ui
# https://docs.digitalocean.com/products/droplets/how-to/manage-agent/
case node['platform']
when 'ubuntu'
  node.default['fb_apt']['sources']['digitalocean_droplet_agent'] = {
    'key' => 'digitalocean_droplet_agent',
    'url' => 'https://repos-droplet.digitalocean.com/apt/droplet-agent',
    'suite' => 'main',
    'components' => ['main'],
  }
  # https://repos-droplet.digitalocean.com/gpg.key
  node.default['fb_apt']['keymap']['digitalocean_droplet_agent'] = <<~EOS
    -----BEGIN PGP PUBLIC KEY BLOCK-----

    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
    =CWqM
    -----END PGP PUBLIC KEY BLOCK-----
  EOS

  node.default['fb_apt']['preferences']['droplet-agent.pref'] = {
    'Package' => '*',
    'Pin' => 'origin repos-droplet.digitalocean.com',
    'Pin-Priority' => '100',
  }
when 'centos'
  node.default['fb_yum_repos']['repos']['digitalocean_droplet_agent'] = {
    'repos' => {
      'digitalocean_droplet_agent' => {
        'name' => 'DigitalOcean Droplet Agent',
        'baseurl' => 'https://repos-droplet.digitalocean.com/yum/droplet-agent/$basearch',
        'repo_gpgcheck' => false,
        'gpgcheck' => true,
        'enabled' => true,
        'gpgkey' => 'https://repos-droplet.digitalocean.com/gpg.key',
        'sslverify' => false,
        'sslcacert' => '/etc/pki/tls/certs/ca-bundle.crt',
        'metadata_expire' => '300',
      },
    },
  }
end

package 'droplet-agent' do
  action :upgrade
end

service 'droplet-agent' do
  only_if { node['boxcutter_digitalocean']['droplet_agent']['enable'] }
  action [:enable, :start]
end

service 'disable droplet-agent' do
  service_name 'droplet-agent'
  not_if { node['boxcutter_digitalocean']['droplet_agent']['enable'] }
  action [:stop, :disable]
end

# droplet-agent requires authorized keys to be in /root/.ssh to work
node.default['fb_ssh']['sshd_config']['PermitRootLogin'] = true
node.default['fb_ssh']['sshd_config']['Match user root'] = {
  'AuthorizedKeysFile' => '.ssh/authorized_keys /etc/ssh/authorized_keys/%u',
}

# Monitoring/metrics agent - need for metrics in web ui
# https://docs.digitalocean.com/products/monitoring/how-to/install-agent/
case node['platform']
when 'ubuntu'
  node.default['fb_apt']['sources']['digitalocean_agent'] = {
    'key' => 'digitalocean_agent',
    'url' => 'https://repos.insights.digitalocean.com/apt/do-agent',
    'suite' => 'main',
    'components' => ['main'],
  }
  # https://repos.insights.digitalocean.com/sonar-agent.asc
  node.default['fb_apt']['keymap']['digitalocean_agent'] = <<~EOS
    -----BEGIN PGP PUBLIC KEY BLOCK-----

    mQINBGNr+DsBEADCVxpd7sQFj5UqRUj+b6wHThGMuCcqoZsOnRWv9YBd2lkbT4KB
    5B97mwJuk/u8hrZjt7LLEezErywJr1yr6xnOSFsTJ9b+A0J9ROGkkb6QoQmXFdhc
    LEXNUOabjMfLQPOdbN63VLrTveoAzzHbiOKnYZZsOi+JIq8WLcFOdBD8lLagtk9M
    i5qoPdvUb9EoJSk/taa2bh2UlCVpWH7GrXD17gn31pFO7xa5lAlRbyEkIVXXslb6
    SNCkPXSilOLecyNApMZ2R605eA/RmodQ4s6ZJ9zcfmJETcwjBArmFL9yOnnF/Xxq
    T3AXpXqwECIvtD/Ig6swkL68UDQilOMC2guQh9NC4juEBBu+SGSZf7DqGySSKYNN
    oFVOf3XyRVwworxu1WeDleaJHy5BX8L5d8IEu1Z4/CbyIyxjEgiOeg0AvqU8EIiG
    CZ2L3m1Hxtr9UFhx1P9VA2jxTlVBuek07cvyCNIPFPzxiPYk03tdZA89CUikZHZV
    Zv7xEdxm+OsK+mXc8RaqCLo7Krq2su71F3/Tw+M/IbKVsKhCndpxlWfpFg053gqy
    r82aAs+60x8Iuj6BTyB++krN3rXGeFFwI8xtFIDwQIKYtOjmP8p6m4X+tbQ8yohp
    /rco6LnZTTyvA/rpoiqrssq1N8eaJrV2NrjcgXM6rNsFecC1HoaZ3ILHAwARAQAB
    tEBEaWdpdGFsT2NlYW4gSW5zaWdodHMgRW5naW5lZXJpbmcgPHNvbmFyLWFnZW50
    QGRpZ2l0YWxvY2Vhbi5jb20+iQJOBBMBCgA4FiEEkCxEtC6poX+FeFEJd7ebP/r3
    72UFAmNr+DsCGwMFCwkIBwIGFQoJCAsCBBYCAwECHgECF4AACgkQd7ebP/r372Wd
    wRAApb67y3noYlm5MRo1Zezql2PbXP2I5JBdQxwVvL4Dv+JAr5nsVvFH4RIGbHC9
    bwh0aLKPosrF8rdG2TdQ3JEfJdnp652+GUC2s8UBgOyz8PvEEnqas1T5cz65wk4Z
    PT3NeDE3ro4UjstV/jh7b3mNZF6RvTJLamerbBqmC2MOwNS29ihfZj1WUFAo3kKa
    xS4UVYuU6mchwcUDUFV3nTx08BnVb66afXIFGYlHeV4Ol7BcM0UHPCpTJI0RQ0h+
    U6WuRzlqcmiiJp1iYa/duIMaM2PpbB1PcRQtKKVUJ/JM+D2yW8/duP/HQeCPK98m
    2exntp7pMm3+XzyJiMkzsmnfBbI/Gi3xyzp0IMAU8nPFvG4IbpspYCbV38G+NxZI
    HZhAdqW8DJlJF+siXixwvdEV3XW+euST6Pog4VNDPsDr/U0967SIf9UzV4mZEexY
    lScVbSN4jVrc4M/G4xB5lcL2Oz9H1lQ209oRw2zhAc4QaVfzY1XHk5iPDGFpbrlO
    zUlaS6TGYupGIkz6y4NNj5+nkR0n8lv2m33p9lxNZsL0esT8I1qVUEQ5k+/8QWth
    6o/qcIa+xBX1x+g4dz5rCGU+krOnil+T76t2gI48k+avwxoCuC74o4+XbbppotMc
    A+6zhBtuiG6jiQgBbBiJKyxh7OO6oJHV5RM7k37xtyK2DoE=
    =AfKf
    -----END PGP PUBLIC KEY BLOCK-----
  EOS
when 'centos'
  node.default['fb_yum_repos']['repos']['digitalocean_agent'] = {
    'repos' => {
      'digitalocean-agent' => {
        'name' => 'DigitalOcean Agent',
        'baseurl' => 'https://repos.insights.digitalocean.com/yum/do-agent/$basearch',
        'repo_gpgcheck' => false,
        'gpgcheck' => true,
        'enabled' => true,
        'gpgkey' => 'https://repos.insights.digitalocean.com/sonar-agent.asc',
        'sslverify' => false,
        'sslcacert' => '/etc/pki/tls/certs/ca-bundle.crt',
        'metadata_expire' => '300',
      },
    },
  }
end

package 'do-agent' do
  action :upgrade
end

service 'do-agent' do
  only_if { node['boxcutter_digitalocean']['metrics_agent']['enable'] }
  action [:enable, :start]
end

service 'disable do-agent' do
  service_name 'do-agent'
  not_if { node['boxcutter_digitalocean']['metrics_agent']['enable'] }
  action [:stop, :disable]
end
