module FB
  class Users
    UID_MAP = {
      # system
      'root' => {
        'uid' => 0,
        'system' => true,
      },
      'nexus' => {
        'uid' => 990,
      },
      'java' => {
        'uid' => 991,
      },
      'anaconda' => {
        'uid' => 993,
      },
      'python' => {
        'uid' => 994,
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
      'nexus' => {
        'gid' => 990,
      },
      'java' => {
        'gid' => 991,
      },
      'docker' => {
        'gid' => 992,
      },
      'anaconda' => {
        'gid' => 993,
      },
      'python' => {
        'gid' => 994,
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
