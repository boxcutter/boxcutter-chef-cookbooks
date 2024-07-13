# Bootstrap Chef in a container

```
docker run -it --rm --privileged ubuntu:22.04

apt-get update
apt-get install -y git
apt-get install -y ca-certificates curl

mkdir -p /var/chef/repos
git clone https://github.com/boxcutter/chef-cookbooks.git /var/chef/repos/chef-cookbooks
git clone https://github.com/boxcutter/boxcutter-chef-cookbooks.git /var/chef/repos/boxcutter-chef-cookbooks

# chefctl uses a shebang that points at /opt/chef, so make sure we have a link
# in place for compatibility
mkdir -p /etc/cinc
# -n must be here in case /etc/chef already exists, otherwise it tries to
#  create /etc/chef/cinc
# /etc/chef -> /etc/cinc
ln -snf /etc/cinc /etc/chef

curl -L https://omnitruck.cinc.sh/install.sh | bash

# /opt/chef -> /opt/cinc
ln -snf /opt/cinc /opt/chef

cat > /etc/cinc/client-prod.rb <<EOF
chef_repo_path '/var/chef/repos/boxcutter-chef-cookbooks'
cookbook_path [
  '/var/chef/repos/chef-cookbooks/cookbooks',
  '/var/chef/repos/boxcutter-chef-cookbooks/cookbooks'
]
follow_client_key_symlink true
client_fork false
no_lazy_load false
local_key_generation true
local_mode true
json_attribs '/etc/cinc/run-list.json'
ohai.critical_plugins ||= []
ohai.critical_plugins += [:Passwd]
ohai.optional_plugins ||= []
ohai.optional_plugins += [:Passwd]
EOF

openssl genrsa -out /etc/cinc/client-prod.pem
openssl genrsa -out /etc/cinc/validation.pem

ln -sf /etc/cinc/client-prod.rb /etc/cinc/client.rb
ln -sf /etc/cinc/client-prod.pem /etc/cinc/client.pem

cat > /etc/chefctl-config.rb <<EOF
chef_client '/opt/cinc/bin/cinc-client'
chef_options ['--no-fork']
log_dir '/var/log/chef'
human true
EOF

cat > /etc/cinc/run-list.json <<EOF
{
  "run_list" : [
    "boxcutter_init::default"
  ]
}
EOF

curl -o /usr/local/sbin/chefctl.rb https://raw.githubusercontent.com/facebook/chef-utils/main/chefctl/src/chefctl.rb
chmod +x /usr/local/sbin/chefctl.rb
ln -sf /usr/local/sbin/chefctl.rb /usr/local/sbin/chefctl


# cheftl creates a default lockfile in /var/lock/subsys/chefctl
mkdir -p /var/lock/subsys
mkdir -p /var/log/chef

apt-get install -y gnupg file

touch /root/firstboot_os
chefctl -iv
```

```
/opt/cinc/bin/cinc-client -c /etc/cinc/client.rb -j /etc/chef/run-list.json
/opt/cinc/bin/cinc-client --config /etc/cinc/client.rb --json-attributes /etc/chef/run-list.json
```
