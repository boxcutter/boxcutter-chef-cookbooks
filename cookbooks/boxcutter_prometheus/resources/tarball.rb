property :package_name, String, name_property: true
property :source, String
property :checksum, String
property :creates, String

action :install do
  tmp_path = ::File.join(Chef::Config[:file_cache_path], ::File.basename(new_resource.source))

  remote_file tmp_path do
    source new_resource.source
    checksum new_resource.checksum
  end

  install_path = "/opt/#{new_resource.package_name}"

  directory install_path do
    owner node.root_user
    group node.root_user
    mode '0755'
  end

  execute 'extract alertmanager' do
    command <<-BASH
      tar --extract --directory #{install_path} --file #{tmp_path}
    BASH
    creates "#{install_path}/#{new_resource.creates}"
  end

  link "#{install_path}/latest" do
    to "#{install_path}/#{new_resource.creates}"
  end
end
