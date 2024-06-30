default['boxcutter_nfs'] = {
  'server' => {
    'config' => {
      'rpcnfsdcount' => 8,
      'rpcnfsdpriority' => 0,
      'rpcmountdopts' => '--manage-gids',
      'need_svcgssd' => nil,
      'rpcsvcgssdopts' => nil,
    },
    'exports' => {},
  },
  'client' => {},
  'idmap' => {
    'general' => {
      'verbosity' => '0'
    },
    'mapping' => {
      'nobody-user' => 'nobody',
      'nobody-group' => 'nogroup',
    }
  }
}
