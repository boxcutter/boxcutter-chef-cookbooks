def self.test_remote_client_rb_extra_code(_hostname)
  <<~EOF

    follow_client_key_symlink true
    client_fork false
    no_lazy_load false
    local_key_generation true
    json_attribs '/etc/cinc/run-list.json'
    require '/etc/cinc/attribute-change-handler.rb'
    ohai.critical_plugins ||= []
    ohai.critical_plugins += [:Passwd]
    ohai.critical_plugins += [:ShardSeed]
    ohai.optional_plugins ||= []
    ohai.optional_plugins += [:Passwd]
    ohai.optional_plugins += [:ShardSeed]
  EOF
end
