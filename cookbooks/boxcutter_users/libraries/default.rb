module FB
  class Users
    UID_MAP = {
      # system
      'root' => {
        'uid' => 0,
        'system' => true,
      },
      'python' => {
        'uid' => 994,
      },
      'boxcutter' => {
        'uid' => 1000,
      },
    }.freeze

    GID_MAP = {
      'root' => {
        'gid' => 0,
        'system' => true,
      },
      'python' => {
        'gid' => 994,
      },
      'boxcutter' => {
        'gid' => 1000,
      },
    }
  end
end
