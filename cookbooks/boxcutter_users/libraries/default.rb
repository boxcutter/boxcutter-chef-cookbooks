module FB
  class Users
    UID_MAP = {
      # system
      'root' => {
        'uid' => 0,
        'system' => true,
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
    }.freeze

    GID_MAP = {
      'root' => {
        'gid' => 0,
        'system' => true,
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
    }.freeze
  end
end
