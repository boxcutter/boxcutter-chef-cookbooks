#
# Cookbook:: boxcutter_docker
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

FB::Users.initialize_group(node, node['boxcutter_docker']['group'])

%w{DOCKER-USER DOCKER-ISOLATION-STAGE-1}.each do |chain|
  node.default['fb_iptables']['dynamic_chains']['filter'][chain] = [
    'FORWARD',
  ]
end
%w{DOCKER DOCKER-ISOLATION-STAGE-2}.each do |chain|
  node.default['fb_iptables']['dynamic_chains']['filter'][chain] = []
end

node.default['fb_iptables']['filter']['FORWARD']['rules']['docker'] = {
  'rules' => [
    '-o docker0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT',
    '-o docker0 -j DOCKER',
    '-i docker0 ! -o docker0 -j ACCEPT',
    '-i docker0 -o docker0 -j ACCEPT',
  ],
}

case node['platform']
when 'ubuntu'
  %w{
    ca-certificates
    curl
    gnupg
    lsb-release
  }.each do |package|
    package package do
      action :upgrade
    end
  end
when 'centos'
  package 'yum-utils' do
    action :upgrade
  end
end

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
  # curl -fsSLO https://download.docker.com/linux/ubuntu/gpg
  #
  # List the key with `gpg --show-keys` like so:
  #
  # gpg --with-fingerprint --show-keys gpg
  #
  # In 2023-11-03 show-keys looked like this:
  #
  # pub   rsa4096 2017-02-22 [SCEA]
  #       9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88
  # uid                      Docker Release (CE deb) <docker@docker.com>
  # sub   rsa4096 2017-02-22 [S]
  # #
  # Use the last 16 digits of the key signature as the key for
  # node.default['fb_apt']['keys']:
  #
  # 8D81 803C 0EBF CD88
  #
  # Then replace the GPG armored blocks with the following markers (content
  # remains the same:
  # -----BEGIN PGP PUBLIC KEY BLOCK-----
  # -----END PGP PUBLIC KEY BLOCK-----
  case node['kernel']['machine']
  when 'aarch64', 'arm64'
    node.default['fb_apt']['repos'] <<
      "deb [arch=arm64] https://download.docker.com/linux/ubuntu #{node['lsb']['codename']} stable"
  when 'x86_64', 'amd64'
    node.default['fb_apt']['repos'] <<
      "deb [arch=amd64] https://download.docker.com/linux/ubuntu #{node['lsb']['codename']} stable"
  end

  node.default['fb_apt']['keys']['8D81803C0EBFCD88'] = <<~EOS
    -----BEGIN PGP PUBLIC KEY BLOCK-----

    mQINBFit2ioBEADhWpZ8/wvZ6hUTiXOwQHXMAlaFHcPH9hAtr4F1y2+OYdbtMuth
    lqqwp028AqyY+PRfVMtSYMbjuQuu5byyKR01BbqYhuS3jtqQmljZ/bJvXqnmiVXh
    38UuLa+z077PxyxQhu5BbqntTPQMfiyqEiU+BKbq2WmANUKQf+1AmZY/IruOXbnq
    L4C1+gJ8vfmXQt99npCaxEjaNRVYfOS8QcixNzHUYnb6emjlANyEVlZzeqo7XKl7
    UrwV5inawTSzWNvtjEjj4nJL8NsLwscpLPQUhTQ+7BbQXAwAmeHCUTQIvvWXqw0N
    cmhh4HgeQscQHYgOJjjDVfoY5MucvglbIgCqfzAHW9jxmRL4qbMZj+b1XoePEtht
    ku4bIQN1X5P07fNWzlgaRL5Z4POXDDZTlIQ/El58j9kp4bnWRCJW0lya+f8ocodo
    vZZ+Doi+fy4D5ZGrL4XEcIQP/Lv5uFyf+kQtl/94VFYVJOleAv8W92KdgDkhTcTD
    G7c0tIkVEKNUq48b3aQ64NOZQW7fVjfoKwEZdOqPE72Pa45jrZzvUFxSpdiNk2tZ
    XYukHjlxxEgBdC/J3cMMNRE1F4NCA3ApfV1Y7/hTeOnmDuDYwr9/obA8t016Yljj
    q5rdkywPf4JF8mXUW5eCN1vAFHxeg9ZWemhBtQmGxXnw9M+z6hWwc6ahmwARAQAB
    tCtEb2NrZXIgUmVsZWFzZSAoQ0UgZGViKSA8ZG9ja2VyQGRvY2tlci5jb20+iQI3
    BBMBCgAhBQJYrefAAhsvBQsJCAcDBRUKCQgLBRYCAwEAAh4BAheAAAoJEI2BgDwO
    v82IsskP/iQZo68flDQmNvn8X5XTd6RRaUH33kXYXquT6NkHJciS7E2gTJmqvMqd
    tI4mNYHCSEYxI5qrcYV5YqX9P6+Ko+vozo4nseUQLPH/ATQ4qL0Zok+1jkag3Lgk
    jonyUf9bwtWxFp05HC3GMHPhhcUSexCxQLQvnFWXD2sWLKivHp2fT8QbRGeZ+d3m
    6fqcd5Fu7pxsqm0EUDK5NL+nPIgYhN+auTrhgzhK1CShfGccM/wfRlei9Utz6p9P
    XRKIlWnXtT4qNGZNTN0tR+NLG/6Bqd8OYBaFAUcue/w1VW6JQ2VGYZHnZu9S8LMc
    FYBa5Ig9PxwGQOgq6RDKDbV+PqTQT5EFMeR1mrjckk4DQJjbxeMZbiNMG5kGECA8
    g383P3elhn03WGbEEa4MNc3Z4+7c236QI3xWJfNPdUbXRaAwhy/6rTSFbzwKB0Jm
    ebwzQfwjQY6f55MiI/RqDCyuPj3r3jyVRkK86pQKBAJwFHyqj9KaKXMZjfVnowLh
    9svIGfNbGHpucATqREvUHuQbNnqkCx8VVhtYkhDb9fEP2xBu5VvHbR+3nfVhMut5
    G34Ct5RS7Jt6LIfFdtcn8CaSas/l1HbiGeRgc70X/9aYx/V/CEJv0lIe8gP6uDoW
    FPIZ7d6vH+Vro6xuWEGiuMaiznap2KhZmpkgfupyFmplh0s6knymuQINBFit2ioB
    EADneL9S9m4vhU3blaRjVUUyJ7b/qTjcSylvCH5XUE6R2k+ckEZjfAMZPLpO+/tF
    M2JIJMD4SifKuS3xck9KtZGCufGmcwiLQRzeHF7vJUKrLD5RTkNi23ydvWZgPjtx
    Q+DTT1Zcn7BrQFY6FgnRoUVIxwtdw1bMY/89rsFgS5wwuMESd3Q2RYgb7EOFOpnu
    w6da7WakWf4IhnF5nsNYGDVaIHzpiqCl+uTbf1epCjrOlIzkZ3Z3Yk5CM/TiFzPk
    z2lLz89cpD8U+NtCsfagWWfjd2U3jDapgH+7nQnCEWpROtzaKHG6lA3pXdix5zG8
    eRc6/0IbUSWvfjKxLLPfNeCS2pCL3IeEI5nothEEYdQH6szpLog79xB9dVnJyKJb
    VfxXnseoYqVrRz2VVbUI5Blwm6B40E3eGVfUQWiux54DspyVMMk41Mx7QJ3iynIa
    1N4ZAqVMAEruyXTRTxc9XW0tYhDMA/1GYvz0EmFpm8LzTHA6sFVtPm/ZlNCX6P1X
    zJwrv7DSQKD6GGlBQUX+OeEJ8tTkkf8QTJSPUdh8P8YxDFS5EOGAvhhpMBYD42kQ
    pqXjEC+XcycTvGI7impgv9PDY1RCC1zkBjKPa120rNhv/hkVk/YhuGoajoHyy4h7
    ZQopdcMtpN2dgmhEegny9JCSwxfQmQ0zK0g7m6SHiKMwjwARAQABiQQ+BBgBCAAJ
    BQJYrdoqAhsCAikJEI2BgDwOv82IwV0gBBkBCAAGBQJYrdoqAAoJEH6gqcPyc/zY
    1WAP/2wJ+R0gE6qsce3rjaIz58PJmc8goKrir5hnElWhPgbq7cYIsW5qiFyLhkdp
    YcMmhD9mRiPpQn6Ya2w3e3B8zfIVKipbMBnke/ytZ9M7qHmDCcjoiSmwEXN3wKYI
    mD9VHONsl/CG1rU9Isw1jtB5g1YxuBA7M/m36XN6x2u+NtNMDB9P56yc4gfsZVES
    KA9v+yY2/l45L8d/WUkUi0YXomn6hyBGI7JrBLq0CX37GEYP6O9rrKipfz73XfO7
    JIGzOKZlljb/D9RX/g7nRbCn+3EtH7xnk+TK/50euEKw8SMUg147sJTcpQmv6UzZ
    cM4JgL0HbHVCojV4C/plELwMddALOFeYQzTif6sMRPf+3DSj8frbInjChC3yOLy0
    6br92KFom17EIj2CAcoeq7UPhi2oouYBwPxh5ytdehJkoo+sN7RIWua6P2WSmon5
    U888cSylXC0+ADFdgLX9K2zrDVYUG1vo8CX0vzxFBaHwN6Px26fhIT1/hYUHQR1z
    VfNDcyQmXqkOnZvvoMfz/Q0s9BhFJ/zU6AgQbIZE/hm1spsfgvtsD1frZfygXJ9f
    irP+MSAI80xHSf91qSRZOj4Pl3ZJNbq4yYxv0b1pkMqeGdjdCYhLU+LZ4wbQmpCk
    SVe2prlLureigXtmZfkqevRz7FrIZiu9ky8wnCAPwC7/zmS18rgP/17bOtL4/iIz
    QhxAAoAMWVrGyJivSkjhSGx1uCojsWfsTAm11P7jsruIL61ZzMUVE2aM3Pmj5G+W
    9AcZ58Em+1WsVnAXdUR//bMmhyr8wL/G1YO1V3JEJTRdxsSxdYa4deGBBY/Adpsw
    24jxhOJR+lsJpqIUeb999+R8euDhRHG9eFO7DRu6weatUJ6suupoDTRWtr/4yGqe
    dKxV3qQhNLSnaAzqW/1nA3iUB4k7kCaKZxhdhDbClf9P37qaRW467BLCVO/coL3y
    Vm50dwdrNtKpMBh3ZpbB1uJvgi9mXtyBOMJ3v8RZeDzFiG8HdCtg9RvIt/AIFoHR
    H3S+U79NT6i0KPzLImDfs8T7RlpyuMc4Ufs8ggyg9v3Ae6cN3eQyxcK3w0cbBwsh
    /nQNfsA6uu+9H7NhbehBMhYnpNZyrHzCmzyXkauwRAqoCbGCNykTRwsur9gS41TQ
    M8ssD1jFheOJf3hODnkKU+HKjvMROl1DK7zdmLdNzA1cvtZH/nCC9KPj1z8QC47S
    xx+dTZSx4ONAhwbS/LN3PoKtn8LPjY9NP9uDWI+TWYquS2U+KHDrBDlsgozDbs/O
    jCxcpDzNmXpWQHEtHU7649OXHP7UeNST1mCUCH5qdank0V1iejF6/CfTFU4MfcrG
    YT90qFF93M3v01BbxP+EIY2/9tiIPbrd
    =0YYh
    -----END PGP PUBLIC KEY BLOCK-----
  EOS
when 'centos'
  node.default['fb_yum_repos']['repos']['docker-ce.repo'] = {
    'repos' => {
      'docker-ce-stable' => {
        'name' => 'Docker CE Stable - $basearch',
        'baseurl' => "https://download.docker.com/linux/centos/#{node['platform_version']}/$basearch/stable",
        'gpgcheck' => true,
        'gpgkey' => 'https://download.docker.com/linux/centos/gpg',
      },
    },
  }
end

case node['platform']
when 'ubuntu'

  package 'docker-ce' do
    version '5:27.3.1-1~ubuntu.22.04~jammy'
  end

  package 'docker-ce-cli' do
    version '5:27.3.1-1~ubuntu.22.04~jammy'
  end

  %w{
    containerd.io
    docker-buildx-plugin
    docker-compose-plugin
  }.each do |package|
    package package do
      action :upgrade
    end
  end
when 'centos'
  %w{
    docker-ce
    docker-ce-cli
    containerd.io
    docker-buildx-plugin
    docker-compose-plugin
  }.each do |package|
    package package do
      action :upgrade
    end
  end
end

template '/etc/docker/daemon.json' do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[docker]'
end

# Since Docker is configured to use systemd and doesn't create the socket, you
# can't rely on Docker's native group configuration to set permissions on the
# Docker API socket. Instead the group permissions need to be configured
# directly in the systemd socket unit file in the override of
# "/lib/systemd/system/docker.socket" in "/etc/systemd/system/docker.socket.d"
fb_systemd_override 'docker-socket-group' do
  unit_name 'docker.socket'
  content lazy {
    { 'Socket' => { 'SocketGroup' => node['boxcutter_docker']['config']['group'] } }
  }
  only_if { node['boxcutter_docker']['config']['group'] }
  notifies :restart, 'service[docker.socket]'
end

# If the docker group is removed, clean up our override
file '/etc/systemd/system/docker.socket.d/docker_socket_group.conf' do
  action :delete
  not_if { node['boxcutter_docker']['config']['group'] }
  notifies :run, 'fb_systemd_reload[system instance]', :immediately
  notifies :restart, 'service[docker.socket]'
end

service 'docker.socket' do
  action :nothing
end

service 'docker' do
  action [:enable, :start]
  only_if { node['boxcutter_docker']['enable'] }
end

service 'disable docker' do
  service_name 'docker'
  action [:stop, :disable]
  not_if { node['boxcutter_docker']['enable'] }
end

boxcutter_docker 'configure' do
  only_if { node['boxcutter_docker']['enable'] }
end
