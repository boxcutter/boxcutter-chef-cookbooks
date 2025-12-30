module FB
  class Users
    UID_MAP = {
      # system
      'root' => {
        'uid' => 0,
        'system' => true,
      },
      'nvidia_gpu_exporter' => {
        'uid' => 684,
      },
      'blackbox_exporter' => {
        'uid' => 685,
      },
      'node_exporter' => {
        'uid' => 686,
      },
      'pushgateway' => {
        'uid' => 687,
      },
      'alertmanager' => {
        'uid' => 688,
      },
      'prometheus' => {
        'uid' => 689,
      },
      'alloy' => {
        'uid' => 691,
        'comment' => 'alloy user',
        'home' => '/var/lib/alloy',
        'shell' => '/sbin/nologin',
      },
      'loki' => {
        'uid' => 692,
        'home' => '/home/loki',
        'shell' => '/bin/false',
      },
      'grafana' => {
        'uid' => 693,
        'home' => '/usr/share/grafana',
        'shell' => '/bin/false',
      },
      '_fluentd' => {
        'uid' => 695,
        'home' => '/var/lib/fluent',
        'shell' => '/usr/sbin/nologin',
      },
      'nexus' => {
        'uid' => 696,
        'home' => '/var/lib/nexus',
        'shell' => '/usr/sbin/nologin',
      },
      # # Start phasing out language-specific UIDs
      # 'java' => {
      #   'uid' => 697,
      # },
      # # Start phasing out language-specific UIDs
      # 'anaconda' => {
      #   'uid' => 698,
      # },
      # # Start phasing out language-specific GIDs
      # 'python' => {
      #   'uid' => 699,
      # },
      'postgres' => {
        'uid' => 700,
      },
      'netbox' => {
        'uid' => 701,
      },
      'redis' => {
        'uid' => 702,
      },
      'boxcutter' => {
        'uid' => 2001,
      },
      'sheila' => {
        'uid' => 2002,
      },
      'taylor' => {
        'uid' => 2003,
      },
      'opuser' => {
        'uid' => 8010,
      },
      'craft' => {
        'uid' => 8011,
      },
      'github-runner' => {
        'uid' => 8012,
      },
      'gitlab-runner' => {
        'comment' => 'GitLab Runner',
        'uid' => 8013,
      },
      'ros' => {
        'uid' => 8014,
      },
    }.freeze

    GID_MAP = {
      'root' => {
        'gid' => 0,
        'system' => true,
      },
      'sudo' => {
        'gid' => 27,
      },
      'users' => {
        'gid' => 100,
      },
      'nvidia_gpu_exporter' => {
        'gid' => 684,
      },
      'blackbox_exporter' => {
        'gid' => 685,
      },
      'node_exporter' => {
        'gid' => 686,
      },
      'pushgateway' => {
        'gid' => 687,
      },
      'alertmanager' => {
        'gid' => 688,
      },
      'prometheus' => {
        'gid' => 689,
      },
      'docker' => {
        'gid' => 690,
      },
      'alloy' => {
        'gid' => 691,
      },
      'grafana' => {
        'gid' => 693,
      },
      '_fluentd' => {
        'gid' => 695,
      },
      'nexus' => {
        'gid' => 696,
      },
      # # Start phasing out language-specific GIDs
      # 'java' => {
      #   'gid' => 697,
      # },
      # # Start phasing out language-specific GIDs
      # 'anaconda' => {
      #   'gid' => 698,
      # },
      # # Start phasing out language-specific GIDs
      # 'python' => {
      #   'gid' => 699,
      # },
      'postgres' => {
        'gid' => 700,
      },
      'netbox' => {
        'gid' => 701,
      },
      'redis' => {
        'gid' => 702,
      },
      'boxcutter' => {
        'gid' => 2001,
      },
      'sheila' => {
        'gid' => 2002,
      },
      'taylor' => {
        'gid' => 2003,
      },
      'opuser' => {
        'gid' => 8010,
      },
      'craft' => {
        'gid' => 8011,
      },
      'github-runner' => {
        'gid' => 8012,
      },
      'gitlab-runner' => {
        'gid' => 8013,
      },
      'ros' => {
        'gid' => 8014,
      },
      'nogroup' => {
        'gid' => 65534,
      },
    }.freeze
  end
end
