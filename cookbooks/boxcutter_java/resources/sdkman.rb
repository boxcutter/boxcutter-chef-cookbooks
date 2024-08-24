action :configure do
  node['boxcutter_java']['sdkman'].each do |sdkman_root, sdkman_data|
    puts "MISCHA: sdkman_root=#{sdkman_root}"
    execute 'run sdkman installer' do
      command <<-BASH
        curl -s "https://get.sdkman.io?rcupdate=false" | bash
      BASH
      user sdkman_data['user']
      group sdkman_data['group']
      live_stream true
      login true
      creates ::File.join(sdkman_root, 'libexec', 'default')
    end

    sdkman_init_path = ::File.join(sdkman_root, 'bin', 'sdkman-init.sh')
    sdkman_data['candidates'].each do |candidate_name, candidate_config|
      candidate_config.keys.each do |candidate_version|
        candidate_path = ::File.join(sdkman_root, 'candidates', candidate_name, candidate_version)
        bash 'install candidate' do
          code <<-BASH
            source "#{sdkman_init_path}"
            sdk install #{candidate_name} #{candidate_version}
          BASH
          user sdkman_data['user']
          group sdkman_data['group']
          live_stream true
          login true
          not_if { ::File.directory?(candidate_path) }
        end
      end
    end
  end
end
