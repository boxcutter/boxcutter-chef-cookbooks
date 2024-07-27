action :configure do
  node['boxcutter_java']['sdkman'].each do |sdkman_root, sdkman_data|
    puts "MISCHA: sdkman_root=#{sdkman_root}"
    execute 'run sdkman installer' do
      command <<-BASH
        curl -s "https://get.sdkman.io?rcupdate=false" | bash
      BASH
      user sdkman_data['user']
      group sdkman_data['group']
      # environment({'SDKMAN_DIR' => sdkman_root})
      live_stream true
      login true
      creates ::File.join(sdkman_root, 'libexec', 'default')
    end

    sdkman_data['candidates'].each do |candidate_name, candidate_version|
      sdkman_init_path = ::File.join(sdkman_root, 'bin', 'sdkman-init.sh')
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
