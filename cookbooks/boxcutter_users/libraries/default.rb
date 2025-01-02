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
      'couchdb' => {
        'uid' => 694,
        'comment' => 'CouchDB Administrator',
        'home' => '/opt/couchdb',
        'shell' => '/bin/bash',
      },
      '_fluentd' => {
        'uid' => 695,
        'home' => '/var/lib/fluent',
        'shell' => '/usr/sbin/nologin',
      },
      'nexus' => {
        'uid' => 696,
      },
      'java' => {
        'uid' => 697,
      },
      'anaconda' => {
        'uid' => 698,
      },
      'python' => {
        'uid' => 699,
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
      'david' => {
        'uid' => 2005,
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
      'couchdb' => {
        'gid' => 694,
      },
      '_fluentd' => {
        'gid' => 695,
      },
      'nexus' => {
        'gid' => 696,
      },
      'java' => {
        'gid' => 697,
      },
      'anaconda' => {
        'gid' => 698,
      },
      'python' => {
        'gid' => 699,
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
      'david' => {
        'gid' => 2005,
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
      'nogroup' => {
        'gid' => 65534,
      },
    }.freeze
  end
end
