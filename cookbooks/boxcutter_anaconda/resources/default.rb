unified_mode true

action :manage do
  node['boxcutter_anaconda']['config'].each do |anaconda_root, anaconda_data|
    use_full_anaconda_install = false
    use_full_anaconda_install = anaconda_data['full_install'] if anaconda_data.key?('full_install')

    conda_binary_path = ::File.join(anaconda_root, 'bin', 'conda')
    unless ::File.exist?(conda_binary_path)
      url, checksum = miniconda3_installer
      url, checksum = anaconda3_installer if use_full_anaconda_install

      filename = ::File.basename(url)
      tmp_path = ::File.join(Chef::Config[:file_cache_path], filename)

      remote_file tmp_path do
        source url
        checksum checksum
      end

      install_prefix = anaconda_root

      directory install_prefix do
        owner anaconda_data['user']
        group anaconda_data['group']
        recursive true
      end

      execute 'run anaconda installer' do
        command <<-BASH
          bash #{tmp_path} -b -f -p #{install_prefix} -s
        BASH
        user anaconda_data['user']
        group anaconda_data['group']
        login true
        creates conda_binary_path
      end
    end

    if anaconda_data.key?('condarc')
      condarc_path = ::File.join(anaconda_root, '.condarc')
      template condarc_path do
        source 'condarc'
        owner anaconda_data['user']
        group anaconda_data['group']
        variables(config: anaconda_data['condarc'])
      end
    end
  end
end

action_class do
  def miniconda3_installer
    # https://docs.conda.io/en/latest/miniconda.html#linux-installers
    #
    # $ bash ./Miniconda3-py311_23.5.2-0-Linux-aarch64.sh -h
    #
    # usage: ./Miniconda3-py311_23.5.2-0-Linux-aarch64.sh [options]
    #
    # Installs Miniconda3 py311_23.5.2-0
    #
    # -b           run install in batch mode (without manual intervention),
    #                                        it is expected the license terms (if any) are agreed upon
    # -f           no error if install prefix already exists
    # -h           print this help message and exit
    # -p PREFIX    install prefix, defaults to /home/anaconda/miniconda3, must not contain spaces.
    # -s           skip running pre/post-link/install scripts
    # -u           update an existing installation
    # -t           run package tests after installation (may install conda-build)

    case node['kernel']['machine']
    when 'x86_64', 'amd64'
      url = 'https://repo.anaconda.com/miniconda/Miniconda3-py311_23.11.0-2-Linux-x86_64.sh'
      checksum = 'c9ae82568e9665b1105117b4b1e499607d2a920f0aea6f94410e417a0eff1b9c'
    when 'aarch64', 'arm64'
      url = 'https://repo.anaconda.com/miniconda/Miniconda3-py311_23.11.0-2-Linux-aarch64.sh'
      checksum = 'decd447fb99dbd0fc5004481ec9bf8c04f9ba28b35a9292afe49ecefe400237f'
    end

    return url, checksum
  end

  def anaconda3_installer
    # https://repo.anaconda.com/archive/
    #
    # $ bash ./Anaconda3-2023.07-1-Linux-aarch64.sh -h
    #
    # usage: ./Anaconda3-2023.07-1-Linux-aarch64.sh [options]
    #
    # Installs Anaconda3 2023.07-1
    #
    # -b           run install in batch mode (without manual intervention),
    #                                        it is expected the license terms (if any) are agreed upon
    # -f           no error if install prefix already exists
    # -h           print this help message and exit
    # -p PREFIX    install prefix, defaults to /home/anaconda/anaconda3, must not contain spaces.
    # -s           skip running pre/post-link/install scripts
    # -u           update an existing installation
    # -t           run package tests after installation (may install conda-build)
    case node['kernel']['machine']
    when 'x86_64', 'amd64'
      url = 'https://repo.anaconda.com/archive/Anaconda3-2023.09-0-Linux-x86_64.sh'
      checksum = '6c8a4abb36fbb711dc055b7049a23bbfd61d356de9468b41c5140f8a11abd851'
    when 'aarch64', 'arm64'
      url = 'https://repo.anaconda.com/archive/Anaconda3-2023.09-0-Linux-aarch64.sh'
      checksum = '69ee26361c1ec974199bce5c0369e3e9a71541de7979d2b9cfa4af556d1ae0ea'
    end

    return url, checksum
  end
end
