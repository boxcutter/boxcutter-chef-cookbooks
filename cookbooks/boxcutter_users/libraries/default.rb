module FB
  class Users
    UID_MAP = {
      # system
      'root' => {
        'uid' => 0,
        'system' => true,
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
      'shelia' => {
        'uid' => 2002,
      },
      'taylor' => {
        'uid' => 2003,
      },
      'craft' => {
        'uid' => 2004,
      },
      'david' => {
        'uid' => 2005,
      },
    }.freeze

    GID_MAP = {
      'root' => {
        'gid' => 0,
        'system' => true,
      },
      'users' => {
        'gid' => 100,
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
      'craft' => {
        'gid' => 2004,
      },
      'david' => {
        'gid' => 2005,
      },
    }.freeze
  end
end
