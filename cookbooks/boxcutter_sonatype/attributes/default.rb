case node['kernel']['machine']
when 'x86_64', 'amd64'
  # https://help.sonatype.com/en/download.html
  sonatype_nexus_version = 'nexus-3.87.1-01'
  sonatype_nexus_url = 'https://download.sonatype.com/nexus/3/nexus-3.87.1-01-linux-x86_64.tar.gz'
  sonatype_nexus_checksum = '9403cc4a78e11af09fc65e217e381dfcf435755dea31cdba9c947d6e1d439cd7'
when 'aarch64', 'arm64'
  sonatype_nexus_version = 'nexus-3.87.1-01'
  sonatype_nexus_url = 'https://download.sonatype.com/nexus/3/nexus-3.87.1-01-linux-aarch_64.tar.gz'
  sonatype_nexus_checksum = '35847fc66895d3bd5cf8582b4d6c22161a00ce36924aed19f9b38107334b2ebb'
end

default['boxcutter_sonatype']['nexus_repository'] = {
  'enable' => true,
  'version' => sonatype_nexus_version,
  'url' => sonatype_nexus_url,
  'checksum' => sonatype_nexus_checksum,
  'nexus_data_dir' => '/var/lib/nexus/nexus-data',
  'manage_admin' => true,
  'admin_username' => nil,
  'admin_password' => nil,
  'vmoptions' => {
    '-Xms2703m' => nil,
    '-Xmx2703m' => nil,
    '-XX:+UnlockDiagnosticVMOptions' => nil,
    '-XX:+LogVMOutput' => nil,
    # '-XX:LogFile' => '/var/lib/nexus/nexus3/log/jvm.log',
    '-XX:-OmitStackTraceInFastThrow' => nil,
    '-Dkaraf.home' => '.',
    '-Dkaraf.base' => '.',
    '-Djava.util.logging.config.file' => 'etc/spring/java.util.logging.properties',
    # '-Dkaraf.data' => '/var/lib/nexus/nexus3',
    # '-Dkaraf.log' => '/var/lib/nexus/nexus3/log',
    # '-Djava.io.tmpdir' => '/var/lib/nexus/nexus3/tmp',
    '-Djdk.tls.ephemeralDHKeySize' => '2048',
    '-Dfile.encoding' => 'UTF-8',
    # additional vmoptions needed for Java9+
    '--add-reads java.xml' => 'java.logging',
    '--add-opens java.base/java.security' => 'ALL-UNNAMED',
    '--add-opens java.base/java.net' => 'ALL-UNNAMED',
    '--add-opens java.base/java.lang' => 'ALL-UNNAMED',
    '--add-opens java.base/java.util' => 'ALL-UNNAMED',
    '--add-opens java.naming/javax.naming.spi' => 'ALL-UNNAMED',
    '--add-opens java.rmi/sun.rmi.transport.tcp' => 'ALL-UNNAMED',
    '--add-exports=java.base/sun.net.www.protocol.http' => 'ALL-UNNAMED',
    '--add-exports=java.base/sun.net.www.protocol.https' => 'ALL-UNNAMED',
    '--add-exports=java.base/sun.net.www.protocol.jar' => 'ALL-UNNAMED',
    '--add-exports=jdk.xml.dom/org.w3c.dom.html' => 'ALL-UNNAMED',
    '--add-exports=jdk.naming.rmi/com.sun.jndi.url.rmi' => 'ALL-UNNAMED',
    '--add-exports=java.security.sasl/com.sun.security.sasl' => 'ALL-UNNAMED',
    '--add-exports=java.base/sun.security.x509' => 'ALL-UNNAMED',
    '--add-exports=java.base/sun.security.rsa' => 'ALL-UNNAMED',
    '--add-exports=java.base/sun.security.pkcs' => 'ALL-UNNAMED',
  },
  'properties' => {
    # https://support.sonatype.com/hc/en-us/articles/360049884673-Considerations-For-NXRM-3-Inside-Air-Gapped-Restricted-Firewalled-and-DMZ-Networks#rhc
    'nexus.skipDefaultRepositories' => true,
  },
  'repositories' => {},
  'roles' => {},
  'users' => {},
  'blobstores' => {
    'default' => {
      'name' => 'default',
      'type' => 'file',
      'path' => 'default',
    },
  },
}
