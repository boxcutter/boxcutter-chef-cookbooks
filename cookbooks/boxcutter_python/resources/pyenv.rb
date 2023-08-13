action :manage do
  node['polymath_python']['pyenv'].each do |pyenv_root, pyenv_data|
    build_environment = {
      'PYENV_ROOT' => pyenv_root,
    }

    execute 'run pyenv installer' do
      command <<-BASH
        curl https://pyenv.run | bash
      BASH
      user pyenv_data['user']
      group pyenv_data['group']
      environment build_environment
      creates pyenv_root
    end

    current_pythons = Dir.glob("#{::File.join(pyenv_root, 'versions')}/*").reject { |f| ::File.symlink?(f) }.sort
    desired_pythons = pyenv_data['pythons'].keys.map { |d| ::File.join(pyenv_root, 'versions', d) }
    pythons_to_delete = current_pythons - desired_pythons
    Chef::Log.info("current_pythons=#{current_pythons}, pythons_to_delete=#{pythons_to_delete}")

    pythons_to_delete.each do |python_name|
      directory python_name do
        recursive true
        action :delete
      end
    end

    current_virtualenvs = Dir.glob("#{::File.join(pyenv_root, 'versions')}/*").select do |f|
                            ::File.symlink?(f)
                          end.map { |f| ::File.basename(f) }.sort
    desired_virtualenvs = pyenv_data['virtualenvs'].keys
    virtualenvs_to_delete = current_virtualenvs - desired_virtualenvs
    Chef::Log.info("current_virtualenvs=#{current_virtualenvs}, virtualenvs_to_delete=#{virtualenvs_to_delete}")

    virtualenvs_to_delete.each do |virtualenv_name|
      boxcutter_python_pyenv_script "pyenv-uninstall-#{virtualenv_name}" do
        code %{eval "$(pyenv virtualenv-init -)" && pyenv uninstall --force #{virtualenv_name}}
        pyenv_root pyenv_root
        user pyenv_data['user']
        group pyenv_data['group']
        live_stream true
        action :run
      end
    end

    pyenv_data['pythons'].each do |python_name, _python_config|
      boxcutter_python_pyenv_script "pyenv-install-#{python_name}" do
        code "pyenv install #{python_name} -v"
        pyenv_root pyenv_root
        user pyenv_data['user']
        group pyenv_data['group']
        environment build_environment
        live_stream true
        not_if { ::File.exist?(::File.join(pyenv_root, 'versions', python_name)) }
        action :run
      end

      boxcutter_python_pyenv_script "upgrade-pip-#{python_name}" do
        code 'python -m pip install -U pip'
        pyenv_root pyenv_root
        user pyenv_data['user']
        group pyenv_data['group']
        environment build_environment
        live_stream true
        not_if { ::File.exist?(::File.join(pyenv_root, 'versions', python_name)) }
        action :run
      end
    end

    pyenv_data['virtualenvs'].each do |virtualenv_name, virtualenv_config|
      virtualenv_python = virtualenv_config['python']

      boxcutter_python_pyenv_script "pyenv-virtualenv-#{virtualenv_name}" do
        code %{eval "$(pyenv virtualenv-init -)" && pyenv virtualenv #{virtualenv_python} #{virtualenv_name}}
        pyenv_root pyenv_root
        user pyenv_data['user']
        group pyenv_data['group']
        environment build_environment
        live_stream true
        not_if { ::File.exist?(::File.join(pyenv_root, 'versions', virtualenv_name)) }
        action :run
      end
    end
  end
end
