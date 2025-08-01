case node['platform']
when 'ubuntu'
  case node['kernel']['machine']
  when 'x86_64', 'amd64'
    package_info = value_for_platform(
      'ubuntu' => {
        '20.04' => {
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.6.2/ubuntu/20.04/cinc_18.6.2-1_amd64.deb',
          'checksum' => '0547888512fdb96a823933bc339ebb28f85796e2ceffae4922cf5e7ee26f094b',
        },
        '22.04' => {
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.6.2/ubuntu/22.04/cinc_18.6.2-1_amd64.deb',
          'checksum' => '043c2cb693d1b6038a3341b471efdb5726d7b08c55f4835a1fb59a6a7f1fba21',
        },
        '24.04' => {
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.6.2/ubuntu/24.04/cinc_18.6.2-1_amd64.deb',
          'checksum' => '48d4e2f5a5befd6a18a90c7dc05aa038a5032825b048e5614dec0e0e83eca42c',
        },
      },
      )
  when 'aarch64', 'arm64'
    package_info = value_for_platform(
      'ubuntu' => {
        '20.04' => {
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.6.2/ubuntu/20.04/cinc_18.6.2-1_arm64.deb',
          'checksum' => 'f3181b8fcf7aee139b317c152e7c2b2a564b8024faa58e568e897ad01bdff782',
        },
        '22.04' => {
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.6.2/ubuntu/22.04/cinc_18.6.2-1_arm64.deb',
          'checksum' => 'a7404177b1bca4eae8b6e79992e6c68606d0da545604635a074cc52ab42dce24',
        },
        '24.04' => {
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.6.2/ubuntu/24.04/cinc_18.6.2-1_arm64.deb',
          'checksum' => 'f36a1b948f0a3559a7eb4ee60c5512586a961c315f135f281faa7f15623ba560',
        },
      },
      )
  end
when 'debian'
  case node['kernel']['machine']
  when 'x86_64', 'amd64'
    package_info = value_for_platform(
      'debian' => {
        '12' => {
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.6.2/debian/12/cinc_18.6.2-1_amd64.deb',
          'checksum' => '311f3f9c19db7d62c9e7a151398853db8d0994e0aeac96189530ee5eb972eb6c',
        },
      },
      )
  when 'aarch64', 'arm64'
    package_info = value_for_platform(
      'debian' => {
        '12' => {
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.6.2/debian/12/cinc_18.6.2-1_arm64.deb',
          'checksum' => 'd3a9190edba47a6946cecd2af010f7c98da02bb56d2a540a93462eb642de8c7f',
        },
      },
      )
  end
when 'centos'
  case node['kernel']['machine']
  when 'x86_64', 'amd64'
    package_info = value_for_platform(
      'centos' => {
        '9' => {
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.6.2/el/9/cinc-18.6.2-1.el9.x86_64.rpm',
          'checksum' => '26ebe3eeb91121def370c44414394fc9a396359c285df6e6a561cfd251cd20f6',
        },
        '10' => {
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.6.2/el/10/cinc-18.6.2-1.el10.x86_64.rpm',
          'checksum' => '3cb1ca62a4fd603f6ee9f8728f04416b3a3226099c6332790357d909936733d5',
        },
      },
      )
  when 'aarch64', 'arm64'
    package_info = value_for_platform(
      'centos' => {
        '9' => {
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.6.2/el/9/cinc-18.6.2-1.el9.aarch64.rpm',
          'checksum' => '3c9091f1f81e7e57410c9d0043fede5c9bc5748d1c204e74b553f726435cf0d2',
        },
        '10' => {
          'url' => 'https://downloads.cinc.sh/files/stable/cinc/18.6.2/el/10/cinc-18.6.2-1.el10.aarch64.rpm',
          'checksum' => 'fa45d047567ebe4ff40d728f586264fc3e0d42c24545f635dcd001bae850b447',
        },
      },
      )
  end
end

default['boxcutter_chef'] = {
  'cinc_client' => {
    'manage_packages' => true,
    'source' => package_info['url'],
    'checksum' => package_info['checksum'],
  },
}
