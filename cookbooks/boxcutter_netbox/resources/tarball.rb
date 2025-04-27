unified_mode true

property :package_name, String, name_property: true
property :version, String, required: true
property :filename, String
property :source, String
property :checksum, String, required: true
property :creates, String, required: true

action :install do
  name = new_resource.package_name

  filename = new_resource.filename || ::File.basename(new_resource.source)
  tmp_path = ::File.join(Chef::Config[:file_cache_path], filename)

  remote_file tmp_path do
    source new_resource.source
    checksum new_resource.checksum
  end

  path = "/opt/#{name}/#{name}-#{new_resource.version}"

  directory "/opt/#{name}" do
    owner node.root_user
    group node['root_group']
    mode '0755'
  end

  directory path do
    owner node.root_user
    group node['root_group']
    mode '0755'
  end

  execute "extract #{name}" do
    command <<-BASH
      tar --extract --strip-components=1 --directory #{path} --file #{tmp_path}
    BASH
    creates "#{path}/#{new_resource.creates}"
  end

  link "/opt/#{name}/latest" do
    to path
  end

  %w{
    /opt/netbox/latest/netbox/media
    /opt/netbox/latest/netbox/reports
    /opt/netbox/latest/netbox/scripts
  }.each do |netbox_path|
    directory netbox_path do
      owner 'netbox'
      group 'netbox'
      recursive true
      action :create
    end
  end
end
