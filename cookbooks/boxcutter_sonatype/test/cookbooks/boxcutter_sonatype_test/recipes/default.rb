#
# Cookbook:: boxcutter_sonatype_test
# Recipe:: default
#
node.default['boxcutter_sonatype']['nexus_repository']['repositories'] = {
  'testy-hosted' => {
    'name' => 'testy-hosted',
    'type' => 'hosted',
    'format' => 'raw',
  },
  'ros-proxy' => {
    'name' => 'ros-proxy',
    'type' => 'proxy',
    'format' => 'apt',
    'remote_url' => 'http://packages.ros.org/ros2/ubuntu',
    'distribution' => 'jammy',
    'flat' => false,
  },
  'docker-proxy' => {
    'name' => 'docker-proxy',
    'type' => 'proxy',
    'format' => 'docker',
    'remote_url' => 'https://registry-1.docker.io',
    'docker_v1_enabled' => true,
    'docker_force_basic_auth' => true,
    'docker_http_port' => 10080,
    'docker_https_port' => 10443,
    'docker_proxy_index_type' => 'HUB',
  },
}

include_recipe 'boxcutter_sonatype::default'

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
  # curl -fsSLO https://raw.githubusercontent.com/ros/rosdistro/master/ros.key
  #
  # List the key with `gpg --show-keys` like so:
  #
  # gpg --with-fingerprint --show-keys ros.key
  #
  # On 2024-0806 show-keys looked like this:
  #
  # pub   rsa4096 2019-05-30 [SC] [expires: 2025-06-01]
  #       C1CF 6E31 E6BA DE88 68B1  72B4 F42E D6FB AB17 C654
  # uid                      Open Robotics <info@osrfoundation.org>
  #
  # Use the last 16 digits of the key signature as the key for
  # node.default['fb_apt']['keys']:
  #
  # F42E D6FB AB17 C654
  #
  # To dump the key contents, run:
  #
  # gpg --enarmor < ros.key > foo.txt
  #
  # Then replace the GPG armored blocks with the following markers (content
  # remains the same:
  # -----BEGIN PGP PUBLIC KEY BLOCK-----
  # -----END PGP PUBLIC KEY BLOCK-----
  node.default['fb_apt']['keys']['F42ED6FBAB17C654'] = <<-EOS
-----BEGIN PGP PUBLIC KEY BLOCK-----

mQINBFzvJpYBEADY8l1YvO7iYW5gUESyzsTGnMvVUmlV3XarBaJz9bGRmgPXh7jc
VFrQhE0L/HV7LOfoLI9H2GWYyHBqN5ERBlcA8XxG3ZvX7t9nAZPQT2Xxe3GT3tro
u5oCR+SyHN9xPnUwDuqUSvJ2eqMYb9B/Hph3OmtjG30jSNq9kOF5bBTk1hOTGPH4
K/AY0jzT6OpHfXU6ytlFsI47ZKsnTUhipGsKucQ1CXlyirndZ3V3k70YaooZ55rG
aIoAWlx2H0J7sAHmqS29N9jV9mo135d+d+TdLBXI0PXtiHzE9IPaX+ctdSUrPnp+
TwR99lxglpIG6hLuvOMAaxiqFBB/Jf3XJ8OBakfS6nHrWH2WqQxRbiITl0irkQoz
pwNEF2Bv0+Jvs1UFEdVGz5a8xexQHst/RmKrtHLct3iOCvBNqoAQRbvWvBhPjO/p
V5cYeUljZ5wpHyFkaEViClaVWqa6PIsyLqmyjsruPCWlURLsQoQxABcL8bwxX7UT
hM6CtH6tGlYZ85RIzRifIm2oudzV5l+8oRgFr9yVcwyOFT6JCioqkwldW52P1pk/
/SnuexC6LYqqDuHUs5NnokzzpfS6QaWfTY5P5tz4KHJfsjDIktly3mKVfY0fSPVV
okdGpcUzvz2hq1fqjxB6MlB/1vtk0bImfcsoxBmF7H+4E9ZN1sX/tSb0KQARAQAB
tCZPcGVuIFJvYm90aWNzIDxpbmZvQG9zcmZvdW5kYXRpb24ub3JnPokCVAQTAQgA
PgIbAwULCQgHAgYVCgkICwIEFgIDAQIeAQIXgBYhBMHPbjHmut6IaLFytPQu1vur
F8ZUBQJgsdhRBQkLTMW7AAoJEPQu1vurF8ZUTMwP/3f7EkOPIFjUdRmpNJ2db4iB
RQu5b2SJRG+KIdbvQBzKUBMV6/RUhEDPjhXZI3zDevzBewvAMKkqs2Q1cWo9WV7Z
PyTkvSyey/Tjn+PozcdvzkvrEjDMftIk8E1WzLGq7vnPLZ1q/b6Vq4H373Z+EDWa
DaDwW72CbCBLWAVtqff80CwlI2x8fYHKr3VBUnwcXNHR4+nRABfAWnaU4k+oTshC
Qucsd8vitNfsSXrKuKyz91IRHRPnJjx8UvGU4tRGfrHkw1505EZvgP02vXeRyWBR
fKiL1vGy4tCSRDdZO3ms2J2m08VPv65HsHaWYMnO+rNJmMZj9d9JdL/9GRf5F6U0
quoIFL39BhUEvBynuqlrqistnyOhw8W/IQy/ymNzBMcMz6rcMjMwhkgm/LNXoSD1
1OrJu4ktQwRhwvGVarnB8ihwjsTxZFylaLmFSfaA+OAlOqCLS1OkIVMzjW+Ul6A6
qjiCEUOsnlf4CGlhzNMZOx3low6ixzEqKOcfECpeIj80a2fBDmWkcAAjlHu6VBhA
TUDG9e2xKLzV2Z/DLYsb3+n9QW7KO0yZKfiuUo6AYboAioQKn5jh3iRvjGh2Ujpo
22G+oae3PcCc7G+z12j6xIY709FQuA49dA2YpzMda0/OX4LP56STEveDRrO+CnV6
WE+F5FaIKwb72PL4rLi4
=i0tj
-----END PGP PUBLIC KEY BLOCK-----
  EOS

  # Omit signed-by and use apt-key to import the key
  # node.default['fb_apt']['repos'] << "deb http://packages.ros.org/ros2/ubuntu #{node['lsb']['codename']} main"
  node.default['fb_apt']['repos'] << "deb http://127.0.0.1:8081/repository/ros-proxy #{node['lsb']['codename']} main"
end

# deb http://packages.ros.org/ros/ubuntu jammy main
