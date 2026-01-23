#!/bin/bash

set -u

CONFDIR='/etc/cinc'
RUN_LIST_FILE="$CONFDIR/run-list.json"
CHEF_PROD_CONFIG='/etc/cinc/client-prod.rb'
CHEFDIR='/var/chef'
REPODIR="$CHEFDIR/repos"

bootstrap() {
  if [ ! -d /opt/cinc ]; then
    mkdir -p $REPODIR
    # Defaulting to cinc-client 18.6.x as that's what Meta upstream currently defaults
    # curl -L https://omnitruck.cinc.sh/install.sh | sudo bash
    curl -L https://omnitruck.cinc.sh/install.sh | sudo bash -s -- -v 18.6.2
  fi
  ln -snf /opt/cinc /opt/chef
  if [ ! -d /etc/cinc ]; then
    mkdir -p $CONFDIR
  fi
  ln -snf $CONFDIR /etc/chef
  cat > $CHEF_PROD_CONFIG <<EOF
local_mode true
chef_repo_path '/var/chef/repos/boxcutter-chef-cookbooks'
cookbook_path ['/var/chef/repos/chef-cookbooks/cookbooks', '/var/chef/repos/boxcutter-chef-cookbooks/cookbooks']
role_path '/var/chef/repo/roles'
follow_client_key_symlink true
client_fork false
no_lazy_load false
local_key_generation true
json_attribs '$RUN_LIST_FILE'
ohai.critical_plugins ||= []
ohai.critical_plugins += [:Passwd]
ohai.optional_plugins ||= []
ohai.optional_plugins += [:Passwd]
EOF

  for key in client-prod validation; do
      file="$CONFDIR/$key.pem"
      if ! [ -e "$file" ]; then
          # Key isn't used in local mode, so no specific options
          # are really necessary
          openssl genrsa -out "$file"
      fi
  done

  ln -sf $CONFDIR/client-prod.rb $CONFDIR/client.rb
  ln -sf $CONFDIR/client-prod.pem $CONFDIR/client.pem
  cp $REPODIR/boxcutter-chef-cookbooks/cookbooks/boxcutter_chef/files/chefctl/chefctl_hooks.rb $CONFDIR/
  cp $REPODIR/boxcutter-chef-cookbooks/cookbooks/boxcutter_chef/files/chefctl/chefctl-config.rb /etc/
  cp $REPODIR/boxcutter-chef-cookbooks/cookbooks/boxcutter_chef/files/chefctl/chefctl.rb /usr/local/sbin/
  ln -s /usr/local/sbin/chefctl.rb /usr/local/sbin/chefctl

  cat >$RUN_LIST_FILE <<EOF
{"run_list":["recipe[boxcutter_ohai]","recipe[boxcutter_init]"]}
EOF
}

if [ "$EUID" -ne 0 ]; then
    echo "Ray, when somebody asks you if you're a god, you say YES!"
    echo "(run this as root)"
    exit 1
fi

if ! [ -d "$REPODIR" ]; then
    echo "Please make /var/chef/repo a git clone of the scale-chef repo"
    exit 1
fi

bootstrap

cat <<'EOF'
sudo su -
touch /root/firstboot_os
echo "{\"tier\": \"minimal\"}" | sudo tee /etc/boxcutter-config.json > /dev/null
sudo chefctl -iv
EOF