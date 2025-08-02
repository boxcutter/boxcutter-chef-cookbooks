property :package_name, String, :name_property => true
property :source, String, :required => true
property :checksum, String, :required => true
property :creates, String, :required => true

action :install do
  tmp_path = ::File.join(Chef::Config[:file_cache_path], ::File.basename(new_resource.source))

  remote_file tmp_path do
    source new_resource.source
    checksum new_resource.checksum
  end

  install_path = "/opt/#{new_resource.package_name}"

  archive_file "extract #{tmp_path}" do
    path tmp_path
    destination install_path
    owner 'root'
    group 'root'
    overwrite :auto
    # This guard shouldn't be necessary as the :auto flag should auto-detect
    # file changes. But adding it just to be safe as I'm not sure how good
    # the timestamps are on prometheus tarballs.
    not_if { ::Dir.exist?("#{install_path}/#{new_resource.creates}") }
  end

  link "#{install_path}/latest" do
    to "#{install_path}/#{new_resource.creates}"
  end
end
