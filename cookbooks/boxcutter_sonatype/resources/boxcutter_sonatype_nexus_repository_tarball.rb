unified_mode true
provides :boxcutter_sonatype_nexus_repository_tarball

property :version, String, :required => true
property :url, String, :required => true
property :checksum, String, :required => true
property :install_root, String, :default => '/opt/sonatype'
property :nexus_install_dir, String, :default => '/opt/sonatype/nexus'

action :install do
  tmp_path = ::File.join(Chef::Config[:file_cache_path], ::File.basename(new_resource.url))

  remote_file tmp_path do
    source new_resource.url
    checksum new_resource.checksum
  end

  # The install tar.gz includes a skeleton `sonatype-work` directory to create
  # an empty data directory. Ignore this path, as we'll manage this in Chef.
  #
  # This sonatype-work tree doesn't have any content, it's just a skeleton:
  #
  # $ tar tzf ./nexus-3.76.1-01-unix.tar.gz
  # nexus-3.76.1-01/...
  # sonatype-work/nexus3/clean_cache
  # sonatype-work/nexus3/log/.placeholder
  # sonatype-work/nexus3/tmp/.placeholder

  directory new_resource.install_root do
    owner 'root'
    group 'root'
    mode '0755'
    recursive true
    action :create
  end

  nexus_version_path = ::File.join(new_resource.install_root, new_resource.version)

  # The install tar.gz includes a skeleton `sonatype-work` directory to create
  # an empty data directory. Ignore this path, as we'll manage this in Chef.
  #
  # This sonatype-work tree doesn't have any content, it's just a skeleton:
  #
  # $ tar tzf ./nexus-3.76.1-01-unix.tar.gz
  # nexus-3.76.1-01/...
  # sonatype-work/nexus3/clean_cache
  # sonatype-work/nexus3/log/.placeholder
  # sonatype-work/nexus3/tmp/.placeholder
  execute 'extract nexus' do
    command <<-BASH
      tar --exclude='sonatype-work*' --keep-directory-symlink --extract --directory '#{new_resource.install_root}' --file #{tmp_path}
    BASH
    # Default: /opt/sonatype/nexus/bin/nexus
    creates ::File.join(nexus_version_path, 'bin', 'nexus')
  end

  # nexus.rc:
  # - is sourced by the nexus startup script in /opt/sonatype/nexus/bin/nexus
  # - controls the user the JVM drops to
  # - is ignored if Nexus is launched by systemd with 'User='
  #
  # Per https://help.sonatype.com/en/run-as-a-service.html, it is expected to
  # assign the user for nexus in 'bin/nexus.rc' (and nexus should not be run
  # as root). From version 3.80 onwards, the nexus.rc is not provided so that
  # file must be created.
  cookbook_file ::File.join(nexus_version_path, 'bin', 'nexus.rc') do
    source 'nexus.rc'
    owner 'root'
    group 'root'
    mode '0644'
  end

  template ::File.join(nexus_version_path, 'bin', 'nexus.vmoptions') do
    source 'nexus.vmoptions.erb'
    owner 'root'
    group 'root'
    mode '0644'
  end

  # example: /opt/sonatype/nexus/ -> /opt/sonatype/nexus-3.76.1-01/
  link ::File.join(new_resource.install_root, 'nexus') do
    to nexus_version_path.to_s
  end
end
