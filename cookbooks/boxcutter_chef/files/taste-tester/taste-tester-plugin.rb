def self.test_remote_client_rb_extra_code(_hostname)
  <<~EOF

    follow_client_key_symlink true
    client_fork false
    no_lazy_load false
    local_key_generation true
    json_attribs '/etc/cinc/run-list.json'
    %w(
      attribute-changed-handler.rb
      resource-updated-handler.rb
    ).each do |handler|
      handler_file = File.join('/etc/cinc/handlers', handler)
      if File.exist?(handler_file)
        require handler_file
      end
    end
    ohai.critical_plugins ||= []
    ohai.critical_plugins += [:Passwd]
    ohai.critical_plugins += [:ShardSeed]
    ohai.optional_plugins ||= []
    ohai.optional_plugins += [:Passwd]
    ohai.optional_plugins += [:ShardSeed]
  EOF
end
