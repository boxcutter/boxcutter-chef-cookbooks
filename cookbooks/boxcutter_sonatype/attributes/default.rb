default['boxcutter_sonatype']['nexus_repository'] = {
  'enable' => true,
  'manage_admin' => true,
  'admin_username' => nil,
  'admin_password' => nil,
  # https://help.sonatype.com/en/directories.html
  'install_root' => '/opt/sonatype', # Where the application and supporting files are stored
  'data_path' => '/opt/sonatype/sonatype-work/nexus3', # Repositories, components and other data
  # https://help.sonatype.com/en/configuring-the-runtime-environment.html
  'runtime' => {
    'properties' => {
      # https://support.sonatype.com/hc/en-us/articles/360049884673-Considerations-For-NXRM-3-Inside-Air-Gapped-Restricted-Firewalled-and-DMZ-Networks#rhc
      'nexus.skipDefaultRepositories' => true,
    },
    # TBD: Manage $install-dir/bin/nexus.vmoptions
    # 'vmoptions' => {
    #   '-Dkaraf.data' => '/opt/sonatype/sonatype-work/nexus3',
    #   '-Djava.io.tmpdir' => '/opt/sonatype-work/nexus3/tmp',
    #   '-XX:LogFile' => '/opt/sonatype-work/nexus3/log/jvm.log',
    #   '-Dkaraf.log' => '/opt/sonatype-work/nexus3/log ',
    # }
  },
  'properties' => {
  },
  'blobstores' => {
    'default' => {
      'name' => 'default',
      'type' => 'file',
      'path' => 'default',
    },
  },
  'repositories' => {},
}
