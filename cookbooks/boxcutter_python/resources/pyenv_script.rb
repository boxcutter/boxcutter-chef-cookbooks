property :pyenv_root, String
property :pyenv_version, String
property :code, String
property :creates, String
property :cwd, String
property :environment, Hash
property :group, String
property :path, Array
property :returns, Array, :default => [0]
property :timeout, Integer
property :user, String
property :umask, [String, Integer]
property :live_stream, [true, false], :default => true

action :run do
  bash new_resource.name do
    code script_code
    creates new_resource.creates if new_resource.creates
    cwd new_resource.cwd if new_resource.cwd
    user new_resource.user if new_resource.user
    group new_resource.group if new_resource.group
    returns new_resource.returns if new_resource.returns
    timeout new_resource.timeout if new_resource.timeout
    umask new_resource.umask if new_resource.umask
    environment(script_environment)
    live_stream new_resource.live_stream
  end
end

action_class do
  def script_code
    script = []
    script << %{export PYENV_ROOT="#{new_resource.pyenv_root}"}
    script << %(export PATH="${PYENV_ROOT}/bin:$PATH")
    script << %{eval "$(pyenv init -)"}
    if new_resource.pyenv_version
      script << %{export PYENV_VERSION="#{new_resource.pyenv_version}"}
    end
    script << new_resource.code
    script.join("\n").concat("\n")
  end

  def script_environment
    script_env = { 'PYENV_ROOT' => new_resource.pyenv_root }
    script_env.merge!(new_resource.environment) if new_resource.environment

    if new_resource.path
      script_env['PATH'] = "#{new_resource.path.join(':')}:#{ENV['PATH']}"
    end

    if new_resource.user
      script_env['USER'] = new_resource.user
      script_env['HOME'] = ::File.expand_path("~#{new_resource.user}")
    end

    script_env
  end
end
