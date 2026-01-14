#
# Cookbook:: boxcutter_ros
# Recipe:: common
#
# Copyright:: 2025-present, Taylor.dev, LLC
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
  locale 'set system locale' do
    lang 'en_US.UTF-8'
  end

  node.default['fb_apt']['sources']['ros'] = {
    'key' => 'ros',
    'url' => node['boxcutter_ros']['mirror'],
    'suite' => node['lsb']['codename'],
    'components' => ['main'],
  }

  # https://github.com/ros-infrastructure/ros-apt-source/releases
  node.default['fb_apt']['keymap']['ros'] = <<~EOS
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
    F8ZUBQJoEhoGBQkUtHZwAAoJEPQu1vurF8ZUv1AP/2gID+uw7pw3WpPevny3pliZ
    JeDx4Y+ut+5c2nCfkpUc3lG50v9ly4ZpNQTWKIm9yB6dxgary7EKpAlGVmiU75JA
    LyftVtjeyQcre2f7Z00u2lXw8Red52AsWHkh/dtctgLSGQiJdTd0donO6cszZFVa
    sCiFdRKlizGvBkE8uFdKYMGixOgnvQZrb9OLqRsoj10aDzN0X3NJk1LTxiS3+udY
    poOk2Bm9VGyrNmgIrYiNqbYPBHYkWGHBqJxvAK92lJ2I/n6X4U8r6sMdDE7QDw4j
    FMdrxC0XmCL4cFPkkR1qadtJy9FiCtpKyqiKuUsCG6AUi5EOY+7Y3oSpKn8Wp1K5
    VMbv12JRIatDIeaAnwa2qyBQVAVC1F/OqWUFKluPjKyMR3DXKwjxpt1P+HUmda0w
    HcnhFIu2th/egmGKH5e3atcVxjAxYfm+f92MN7fFEuFQsMZhI/gt3IgESWrgdaAz
    opRInrMz7yEtz3VaaehwmUUR2gevPQMzBRaA+NIqMLDUvV5jujvFe8c1VUtBLTYc
    /alBiM/Mo1niy3aUfDahzhTr6zz+ur6BFRnNFWv56M3NOVlreNm3NIbNX2kTKh0Z
    QJSSCklJuDUqnPmAzT2BZWUpwfe7QYRwvQhF0YB2N1LavyNwiyfinCQlAh+Q9eme
    2jqGsxvQym3sAPnWvA68
    =xH9H
    -----END PGP PUBLIC KEY BLOCK-----
  EOS
when 'centos'
  # TODO: locale UTF-8 equivalent for rhel

  node.default['fb_yum_repos']['repos']['ros2'] = {
    'repos' => {
      'ros2' => {
        'name' => 'ROS 2 - $basearch',
        'baseurl' => 'http://packages.ros.org/ros2/rhel/$releasever/$basearch/',
        'enabled' => true,
        'gpgcheck' => false,
        'gpgkey' => 'https://repo.ros2.org/repos.key',
        'repo_gpgcheck' => true,
      },
      'ros2-source' => {
        'name' => 'ROS 2 - Source',
        'baseurl' => 'http://packages.ros.org/ros2/rhel/$releasever/SRPMS/',
        'enabled' => false,
        'gpgcheck' => false,
        'gpgkey' => 'https://repo.ros2.org/repos.key',
        'repo_gpgcheck' => true,
      },
    },
  }
end
