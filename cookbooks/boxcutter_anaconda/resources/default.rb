unified_mode true

action :manage do
  node['boxcutter_anaconda']['config'].each do |anaconda_root, anaconda_data|
    use_full_anaconda_install = false
    use_full_anaconda_install = anaconda_data['full_install'] if anaconda_data.has_key?('full_install')

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

    if anaconda_data.has_key?('condarc')
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
      url = 'https://repo.anaconda.com/miniconda/Miniconda3-py311_23.5.2-0-Linux-x86_64.sh'
      checksum = '634d76df5e489c44ade4085552b97bebc786d49245ed1a830022b0b406de5817'
    when 'aarch64', 'arm64'
      url = 'https://repo.anaconda.com/miniconda/Miniconda3-py311_23.5.2-0-Linux-aarch64.sh'
      checksum = '3962738cfac270ae4ff30da0e382aecf6b3305a12064b196457747b157749a7a'
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
      url = 'https://repo.anaconda.com/archive/Anaconda3-2023.07-1-Linux-x86_64.sh'
      checksum = '111ce0a7f26e606863008a9519fd608b1493e483b6f487aea71d82b13fe0967e'
    when 'aarch64', 'arm64'
      url = 'https://repo.anaconda.com/archive/Anaconda3-2023.07-1-Linux-aarch64.sh'
      checksum = '2ebe549375f3f5ffec9558a8a8405ebd697e69c8133b8f9c1c5cd4ff69d1cc74'
    end

    return url, checksum
  end
end
