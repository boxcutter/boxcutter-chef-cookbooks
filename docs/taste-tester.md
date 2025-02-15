# Taste Tester

```
sudo apt-get update
# to build rugged for taste-tester
sudo apt-get install pkg-config
# to build rugged extensions for taste-tester
sudo apt-get install cmake
# we need to install rugged with special openssl settings, or it will get
# linked against the system openssl and won't work properly
export OPENSSL_ROOT_DIR=/opt/cinc-workstation/embedded

$ eval "$(cinc shell-init bash)"
$ which cinc
/opt/cinc-workstation/bin/cinc

# macos:
# install xcode
# brew install pkg-config
# brew install cmake

cinc gem install taste_tester

sudo mkdir -p /usr/local/etc/taste-tester
# sudo cp ~/github/boxcutter/boxcutter-chef-cookbooks/cookbooks/boxcutter_chef/files/taste-tester/taste-tester-plugin.rb /usr/local/etc/taste-tester
# sudo cp ~/github/boxcutter/boxcutter-chef-cookbooks/cookbooks/boxcutter_chef/files/taste-tester/taste-tester.conf /usr/local/etc/taste-tester

sudo tee /usr/local/etc/taste-tester/taste-tester-plugin.rb <<'EOF'
def self.test_remote_client_rb_extra_code(_hostname)
  <<~EOF

    follow_client_key_symlink true
    client_fork false
    no_lazy_load false
    local_key_generation true
    json_attribs '/etc/cinc/run-list.json'
    ohai.critical_plugins ||= []
    ohai.critical_plugins += [:Passwd]
    ohai.critical_plugins += [:ShardSeed]
    ohai.optional_plugins ||= []
    ohai.optional_plugins += [:Passwd]
    ohai.optional_plugins += [:ShardSeed]
  EOF
end
EOF


sudo tee /usr/local/etc/taste-tester/taste-tester.conf <<EOF
repo File.join(ENV['HOME'], 'github', 'boxcutter', 'boxcutter-chef-cookbooks')
repo_type 'auto'
base_dir ''
cookbook_dirs ['cookbooks', '../chef-cookbooks/cookbooks']
# For now don't declare databag_dir - between meals seems to have a bug where it hardcodes debug_level=info
# databag_dir 'data_bags'
role_dir 'roles'
role_type 'rb'
chef_config_path '/etc/chef'
chef_config 'client.rb'
ref_file "#{ENV['HOME']}/.chef-cache/scale-taste-tester-ref.json"
checksum_dir "#{ENV['HOME']}/.chef-cache/checksums"
chef_client_command '/usr/local/sbin/chefctl -i'
use_ssl false
use_ssh_tunnels true
ssh_command '/usr/bin/ssh -o StrictHostKeyChecking=no'
chef_zero_path '/opt/cinc-workstation/bin/cinc-zero'
chef_zero_logging true
user ENV['USER']
plugin_path '/usr/local/etc/taste-tester/taste-tester-plugin.rb'
EOF
```

```
# tt test -ys <yourhost>
taste-tester test \
  -c /usr/local/etc/taste-tester/taste-tester.conf \
  -s 10.63.46.39 -v --user taylor -y

taste-tester upload \
  -c /usr/local/etc/taste-tester/taste-tester.conf \
  -s 10.63.46.39 --user taylor -v

taste-tester untest -s 10.63.46.39 --user taylor -v
```
