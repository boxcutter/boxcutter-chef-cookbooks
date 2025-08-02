unified_mode true

property :package_name, String, :name_property => true
property :bin_links, Array, :default => []

action :install do
  package 'unzip'

  name = new_resource.package_name

  # https://app-updates.agilebits.com/product_history/CLI2
  # https://developer.1password.com/docs/cli/install-server/
  # For now we pin the version so we can pass in a sha256 checksum to the remote_file resource
  # so that it won't try to re-download if there is no update
  case node['kernel']['machine']
  when 'x86_64', 'amd64'
    package_info = {
      'url' => 'https://cache.agilebits.com/dist/1P/op2/pkg/v2.31.1/op_linux_amd64_v2.31.1.zip',
      'checksum' => '2e98f0df5977f57bcb2f3e8835e2837660ee4915456ee8ed124e0588a429a5c9',
    }
  when 'aarch64', 'arm64'
    package_info = {
      'url' => 'https://cache.agilebits.com/dist/1P/op2/pkg/v2.31.1/op_linux_arm64_v2.31.1.zip',
      'checksum' => '87292a7c0546e181526b4f362720a76f9e46bbb6cc24addd44b7573541dd9ab8',
    }
  end

  filename = ::File.basename(package_info['url'])
  tmp_path = ::File.join(Chef::Config[:file_cache_path], filename)

  remote_file tmp_path do
    source package_info['url']
    checksum package_info['checksum']
  end

  binary_path = "/opt/#{name}/bin"

  [
    '/opt',
    "/opt/#{name}",
    binary_path,
  ].each do |path|
    directory path do
      owner node.root_user
      group node['root_group']
      mode '0755'
    end
  end

  execute "extract #{name}" do
    command <<-BASH
      unzip -od #{binary_path} #{tmp_path}
    BASH
    creates "#{binary_path}/#{name}"
  end

  new_resource.bin_links.each do |link_name|
    link "/usr/local/bin/#{link_name}" do
      to "#{binary_path}/#{name}"
    end
  end
end
