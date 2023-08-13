property :package_name, String, name_property: true
property :version, String
property :user, String
property :group, String
property :pyenv_root, String
property :pyenv_version, String
property :environment, String
property :live_stream, [true, false], default: true

action :install do
  pip_package_installed?(new_resource.package_name, new_resource.version)

  command = if new_resource.version
              "pip install #{new_resource.package_name}==#{new_resource.version}"
            else
              "pip install #{new_resource.package_name}"
            end

  boxcutter_python_pyenv_script "pip-install#{new_resource.package_name}-#{new_resource.pyenv_version}" do
    code %(eval "$(pyenv virtualenv-init -)" && #{command})
    pyenv_root new_resource.pyenv_root
    pyenv_version new_resource.pyenv_version
    user new_resource.user
    group new_resource.group
    live_stream true
    not_if { pip_package_installed?(new_resource.package_name, new_resource.version) }
  end
end

action_class do
  def pip_package_installed?(python_package, python_version)
    cmd = Mixlib::ShellOut.new(script_code(%(eval "$(pyenv virtualenv-init -)" && pip freeze --all)), user: new_resource.user, group: new_resource.group, environment: script_environment)
    cmd.run_command
    package_string = if python_version.nil?
                       "#{python_package}==#{python_version}"
                     else
                       python_package
                     end
    cmd.stdout.include?(package_string)
  end

  def script_code(command)
    script = []
    script << %(export PYENV_ROOT="#{new_resource.pyenv_root}")
    script << %(export PATH="${PYENV_ROOT}/bin:$PATH")
    script << %{eval "$(pyenv init -)"}
    if new_resource.pyenv_version
      script << %(export PYENV_VERSION="#{new_resource.pyenv_version}")
    end
    script << command
    script.join("\n").concat("\n")
  end

  def script_environment
    script_env = { 'PYENV_ROOT' => new_resource.pyenv_root }
    script_env.merge!(new_resource.environment) if new_resource.environment

    if new_resource.user
      script_env['USER'] = new_resource.user
      script_env['HOME'] = ::File.expand_path("~#{new_resource.user}")
    end

    script_env
  end
end
