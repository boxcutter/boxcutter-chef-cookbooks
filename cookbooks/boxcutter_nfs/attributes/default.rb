case node['platform_family']
when 'rhel'
  default['boxcutter_nfs'] = {
    'server' => {
      'nfs_conf' => {
        'general' => {},
        'nfsrahead' => {},
        'exports' => {},
        'exportfs' => {},
        'gssd' => {
          'use-gss-proxy' => '1',
        },
        'lockd' => {},
        'exportd' => {},
        'mountd' => {},
        'nfsdcld' => {},
        'nfsdcltrack' => {},
        'nfsd' => {
          'vers3' => 'n',
          'rdma' => 'y',
          'rdma-port' => '20049',
        },
        'statd' => {},
        'sm-notify' => {},
      },
      'exports' => {},
    },
    'client' => {},
    'idmap' => {
      'general' => {}
      'mapping' => {},
      'translation' => {},
      'static' => {},
      'UMICH_SCHEMA' => {
        'LDAP_server' => 'ldap-server.local.domain.edu',
        'LDAP_base' => 'dc=local,dc=domain,dc=edu',
      }
    }
when 'debian'
  default['boxcutter_nfs'] = {
    'server' => {
      'nfs_conf' => {
        'general' => {
          'pipefs-directory' => '/run/rpc_pipefs',
        },
        'exports' => {},
        'exportfs' => {},
        'gssd' => {},
        'lockd' => {},
        'mountd' => {
          'manage-gids' => 'y',
        },
        'nfsdcld' => {},
        'nfsdcltrack' => {},
        'nfsd' => {},
        'statd' => {},
        'sm-notify' => {},
        'svcgssd' => {},
      },
      'nfs_kernel_server' => {
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
end
