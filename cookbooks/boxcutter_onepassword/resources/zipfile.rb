unified_mode true

property :package_name, String, name_property: true
property :bin_links, Array, default: []

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
      'url' => 'https://cache.agilebits.com/dist/1P/op2/pkg/v2.27.0/op_linux_amd64_v2.27.0.zip',
      'checksum' => 'e076905292bba0d6e459353f89fd1d29b626f37e610ee56299bcf8c9201e0405',
    }
  when 'aarch64', 'arm64'
    package_info = {
      'url' => 'https://cache.agilebits.com/dist/1P/op2/pkg/v2.27.0/op_linux_arm64_v2.27.0.zip',
      'checksum' => '3ee60ec19020fb2bb43c3a73a2aa1988d85dd651eedb195b72d555f329737502',
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
