module FB
  class Users
    UID_MAP = {
      # system
      'root' => {
        'uid' => 0,
        'system' => true,
      },
      'couchdb' => {
        'uid' => 694,
        'comment' => 'CouchDB Administrator',
        'home' => '/opt/couchdb',
        'shell' => '/bin/bash',
      },
      '_fluentd' => {
        'uid' => 695,
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
      'docker' => {
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
    }.freeze
  end
end
