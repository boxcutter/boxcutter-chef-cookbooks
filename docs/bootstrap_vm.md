Bootstrapping Chef
==================

Table of Contents
-----------------

- [Ubuntu x86_64](#ubuntu-x86_64)
- [CentOS x86_64](#centos-x86_64)
- [Ubuntu NVIDIA Jetson](#ubuntu-nvidia-jetson)

Ubuntu x86_64
-------------

### Spin up Ubuntu 24.04 x86_64 cloud image as a VM

Download and import the Ubuntu cloud image template into kvm:

```
# Download and import the Ubuntu cloud image itself into kvm
$ mkdir -p ubuntu-server-2404
$ cd ubuntu-server-2404
$ curl -LO http://cloud-images.ubuntu.com/noble/current/SHA256SUMS
$ curl -LO http://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img

$ qemu-img info noble-server-cloudimg-amd64.img

$ sudo qemu-img convert \
  -f qcow2 \
  -O qcow2 \
  noble-server-cloudimg-amd64.img \
  /var/lib/libvirt/images/ubuntu-server-2404.qcow2
$ sudo qemu-img resize \
  -f qcow2 \
  /var/lib/libvirt/images/ubuntu-server-2404.qcow2 \
  64G

# Create a cloud-init template to customize the Ubuntu image in kvm:
touch network-config

cat >meta-data <<EOF
instance-id: ubuntu-server-2404
local-hostname: ubuntu-server-2404
EOF

cat >user-data <<EOF
#cloud-config
users:
  - name: automat
    plain_text_passwd: superseekret
    uid: 63112
    primary_group: users
    groups: users
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
chpasswd: { expire: False }
ssh_pwauth: True
package_update: false
package_upgrade: false
packages:
  - qemu-guest-agent
EOF

sudo apt-get update
sudo apt-get install genisoimage
genisoimage \
    -input-charset utf-8 \
    -output ubuntu-server-2404-cloud-init.img \
    -volid cidata -rational-rock -joliet \
    user-data meta-data network-config
sudo cp ubuntu-server-2404-cloud-init.img \
  /var/lib/libvirt/boot/ubuntu-server-2404-cloud-init.iso
```

Initialize the virtual machine:

```
# Perform a customization run by loading the cloud-init image with the VM
virt-install \
  --connect qemu:///system \
  --name ubuntu-server-2404 \
  --boot uefi \
  --memory 4096 \
  --vcpus 2 \
  --os-variant ubuntu24.04 \
  --disk /var/lib/libvirt/images/ubuntu-server-2404.qcow2,bus=virtio \
  --disk /var/lib/libvirt/boot/ubuntu-server-2404-cloud-init.iso,device=cdrom \
  --network network=host-network,model=virtio \
  --graphics spice \
  --noautoconsole \
  --console pty,target_type=serial \
  --import \
  --debug

# Login to the VM with automat/superseekret
virsh console ubuntu-server-2404
# login with automat/superseekret

# Verify that cloud-init is done (wait until it shows "done" status)
$ cloud-init status
status: done

# Check networking - you may notice that the network interface is down and
# the name of the interface generated in netplan doesn't match. If not
# correct, can regenerate with cloud-init
$ ip --brief a

# Check to make sure cloud-init is greater than 23.4
$ cloud-init --version
/usr/bin/cloud-init 24.1.3-0ubuntu1~22.04.1

# Regenerate only the network config
$ sudo cloud-init clean --configs network
$ sudo cloud-init init --local
$ sudo reboot

# Now netplan should be configured to use the correct interface


# Once everything looks good, disable cloud-init
$ sudo touch /etc/cloud/cloud-init.disabled

$ cloud-init status
status: disabled

$ sudo shutdown -h now

# Detach the cloud-init image
$ virsh domblklist ubuntu-server-2404

$ virsh change-media ubuntu-server-2404 sda --eject
Successfully ejected media.

$ sudo rm /var/lib/libvirt/boot/ubuntu-server-2404-cloud-init.iso

# Make a snapshot of this clean config so you can revert in the future
virsh snapshot-create-as --domain ubuntu-server-2404 --name clean --description "Initial install"

# Nameless snapshot
virsh snapshot-create ubuntu-server-2404
virsh snapshot-list ubuntu-server-2404
virsh snapshot-revert ubuntu-server-2404 clean
virsh snapshot-delete ubuntu-server-2404 clean

# If you need to destroy and recreate....
virsh destroy ubuntu-server-2404
virsh undefine ubuntu-server-2404 --nvram --remove-all-storage
```

### Install cinc-client and chefctl in the image

```
# Login to the VM with automat/superseekret
virsh console ubuntu-server-2404
# login with automat/superseekret

# chefctl uses a shebang that points at /opt/chef, so make sure we have a link
# in place for compatibility
sudo mkdir -p /etc/cinc
# -n must be here in case /etc/chef already exists, otherwise
# it tries to create /etc/chef/cinc
# /etc/chef -> /etc/cinc
sudo ln -snf /etc/cinc /etc/chef

curl -L https://omnitruck.cinc.sh/install.sh | sudo bash
curl -L https://omnitruck.cinc.sh/install.sh | sudo bash -s -- -v 18.6.2


# /opt/chef -> /opt/cinc
sudo ln -snf /opt/cinc /opt/chef

## prime onepassword secret /etc/cinc/op_service_account_token
## Install 1Password cli
# sudo apt-get update
# sudo apt-get install unzip
# ARCH="<choose between 386/amd64/arm/arm64>"
# curl -o /tmp/op.zip https://cache.agilebits.com/dist/1P/op2/pkg/v2.30.3/op_linux_amd64_v2.30.3.zip
# sudo unzip /tmp/op.zip op -d /usr/local/bin/
# rm -f /tmp/op.zip

# op user get --me

sudo tee /etc/cinc/client-prod.rb <<EOF
local_mode true
chef_repo_path '/var/chef/repos/boxcutter-chef-cookbooks'
cookbook_path ['/var/chef/repos/chef-cookbooks/cookbooks', '/var/chef/repos/boxcutter-chef-cookbooks/cookbooks']
follow_client_key_symlink true
client_fork false
no_lazy_load false
local_key_generation true
json_attribs '/etc/cinc/run-list.json'
ohai.critical_plugins ||= []
ohai.critical_plugins += [:Passwd]
ohai.optional_plugins ||= []
ohai.optional_plugins += [:Passwd]
EOF

sudo openssl genrsa -out /etc/cinc/client-prod.pem
sudo openssl genrsa -out /etc/cinc/validation.pem

sudo ln -sf /etc/cinc/client-prod.rb /etc/chef/client.rb
sudo ln -sf /etc/cinc/client-prod.pem /etc/chef/client.pem

sudo tee /etc/chef/chefctl_hooks.rb <<EOF
EOF

sudo tee /etc/chefctl-config.rb <<EOF
chef_client '/opt/cinc/bin/cinc-client'
chef_options ['--no-fork']
log_dir '/var/log/chef'
EOF

sudo tee /etc/chef/run-list.json <<EOF
{
  "run_list" : [
    "recipe[boxcutter_ohai]",
    "recipe[boxcutter_init]"
  ]
}
EOF

sudo apt-get install git
sudo mkdir -p /var/chef /var/chef/repos /var/log/chef
cd /var/chef/repos
sudo git clone https://github.com/boxcutter/chef-cookbooks.git \
  /var/chef/repos/chef-cookbooks
sudo git clone https://github.com/boxcutter/boxcutter-chef-cookbooks.git \
  /var/chef/repos/boxcutter-chef-cookbooks

sudo mkdir -p /usr/local/sbin
sudo curl -o /usr/local/sbin/chefctl.rb \
  https://raw.githubusercontent.com/facebook/chef-utils/main/chefctl/src/chefctl.rb
sudo chmod +x /usr/local/sbin/chefctl.rb
sudo ln -sf /usr/local/sbin/chefctl.rb /usr/local/sbin/chefctl

sudo touch /root/firstboot_os
echo "{\"tier\": \"robot\"}" | sudo tee /etc/boxcutter-config.json > /dev/null
sudo chefctl -iv

# Behind the scenes, it'sdoing this:
# /opt/cinc/bin/cinc-client -c /etc/cinc/client.rb -j /etc/chef/run-list.json
# /opt/cinc/bin/cinc-client --config /etc/cinc/client.rb --json-attributes /etc/chef/run-list.json
```

CentOS x86_64
-------------

```
$ mkdir -p centos-stream-9 && cd centos-stream-9
$ curl -LO https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-x86_64-9-latest.x86_64.qcow2.SHA256SUM
$ curl -LO https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-x86_64-9-latest.x86_64.qcow2

$ qemu-img info CentOS-Stream-GenericCloud-x86_64-9-latest.x86_64.qcow2
image: CentOS-Stream-GenericCloud-x86_64-9-latest.x86_64.qcow2
file format: qcow2
virtual size: 10 GiB (10737418240 bytes)
disk size: 1.12 GiB
cluster_size: 65536
Format specific information:
    compat: 0.10
    compression type: zlib
    refcount bits: 16

$ sudo qemu-img convert \
  -f qcow2 \
  -O qcow2 \
   CentOS-Stream-GenericCloud-x86_64-9-latest.x86_64.qcow2 \
  /var/lib/libvirt/images/centos-stream-9.qcow2
$ sudo qemu-img resize \
  -f qcow2 \
  /var/lib/libvirt/images/centos-stream-9.qcow2 \
  64G

# Create a cloud-init template to customize the Ubuntu image in kvm:
touch network-config

cat >meta-data <<EOF
instance-id: centos-stream-9
local-hostname: centos-stream-9
EOF

cat >user-data <<EOF
#cloud-config
users:
  - name: automat
    plain_text_passwd: superseekret
    uid: 63112
    primary_group: users
    groups: users
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
chpasswd: { expire: False }
ssh_pwauth: True
package_update: false
package_upgrade: false
packages:
  - qemu-guest-agent
EOF

sudo apt-get update
sudo apt-get install genisoimage
genisoimage \
    -input-charset utf-8 \
    -output centos-stream-9-cloud-init.img \
    -volid cidata -rational-rock -joliet \
    user-data meta-data network-config
sudo cp centos-stream-9-cloud-init.img /var/lib/libvirt/boot/centos-stream-9-cloud-init.iso
```

Initialize the virtual machine:

```
# Perform a customization run by loading the cloud-init image with the VM
virt-install \
  --connect qemu:///system \
  --name centos-stream-9 \
  --boot uefi \
  --memory 4096 \
  --vcpus 2 \
  --os-variant centos8 \
  --disk /var/lib/libvirt/images/centos-stream-9.qcow2,bus=virtio \
  --disk /var/lib/libvirt/boot/centos-stream-9-cloud-init.iso,device=cdrom \
  --network network=host-network,model=virtio \
  --graphics spice \
  --noautoconsole \
  --console pty,target_type=serial \
  --import \
  --debug

# Login to the VM with automat/superseekret
virsh console centos-stream-9
# login with automat/superseekret

# Verify that cloud-init is done (wait until it shows "done" status)
$ cloud-init status
status: done

# Check networking - you may notice that the network interface is down and
# the name of the interface generated in netplan doesn't match. If not
# correct, can regenerate with cloud-init
$ ip --brief a

# Check cloud-init version
$ cloud-init --version
/usr/bin/cl
oud-init
23.4-11.el9

# Regenerate only the network config
$ sudo cloud-init clean --configs network
$ sudo cloud-init init --local
$ sudo reboot

# Now networking should be configured to use the correct interface


# Once everything looks good, disable cloud-init
$ sudo touch /etc/cloud/cloud-init.disabled

# Verify cloud-init is disabled
$ sudo cloud-init status
status: disabled

$ sudo shutdown -h now

# Detach the cloud-init image
$ virsh domblklist centos-stream-9
 Target   Source
----------------------------------------------------------------
 vda      /var/lib/libvirt/images/centos-stream-9.qcow2
 sda      /var/lib/libvirt/boot/centos-stream-9-cloud-init.iso

$ virsh change-media centos-stream-9 sda --eject
Successfully ejected media.

$ sudo rm /var/lib/libvirt/boot/centos-stream-9-cloud-init.iso

# Make a snapshot of this clean config so you can revert in the future
virsh snapshot-create-as --domain centos-stream-9 --name clean --description "Initial install"

# Nameless snapshot
virsh snapshot-create centos-stream-9
virsh snapshot-list centos-stream-9
virsh snapshot-revert centos-stream-9 clean
virsh snapshot-delete centos-stream-9 clean

# If you need to destroy and recreate....
virsh destroy centos-stream-9
virsh undefine centos-stream-9 --nvram --remove-all-storage
```

Run syscheck

```
docker container run --rm --interactive --tty \
  --mount type=bind,source="$(pwd)",target=/share \
  docker.io/boxcutter/cinc-auditor exec cinc-client \
    --password superseekret \
    --target ssh://cloud-user@10.63.46.148
```

### Install cinc-client and chefctl in the image - centos-stream-9

```
virsh start centos-stream-9
# Login to the VM with automat/superseekret
virsh console centos-stream-9
# login with automat/superseekret

# chefctl uses a shebang that points at /opt/chef, so make sure we have a link
# in place for compatibility
sudo mkdir -p /etc/cinc
# -n must be here in case /etc/chef already exists, otherwise
# it tries to create /etc/chef/cinc
# /etc/chef -> /etc/cinc
sudo ln -snf /etc/cinc /etc/chef

curl -L https://omnitruck.cinc.sh/install.sh | sudo bash -s -- -v 18.4.12

# /opt/chef -> /opt/cinc
sudo ln -snf /opt/cinc /opt/chef

# prime onepassword secret /etc/cinc/op_service_account_token
# Install 1Password cli
sudo dnf install unzip
ARCH="<choose between 386/amd64/arm/arm64>"
curl -o /tmp/op.zip https://cache.agilebits.com/dist/1P/op2/pkg/v2.30.3/op_linux_amd64_v2.30.3.zip
sudo unzip /tmp/op.zip op -d /usr/local/bin/
rm -f /tmp/op.zip

# op user get --me

sudo tee /etc/cinc/client-prod.rb <<EOF
local_mode true
chef_repo_path '/var/chef/repos/boxcutter-chef-cookbooks'
cookbook_path ['/var/chef/repos/chef-cookbooks/cookbooks', '/var/chef/repos/boxcutter-chef-cookbooks/cookbooks']
follow_client_key_symlink true
client_fork false
no_lazy_load false
local_key_generation true
json_attribs '/etc/cinc/run-list.json'
ohai.critical_plugins ||= []
ohai.critical_plugins += [:Passwd]
ohai.optional_plugins ||= []
ohai.optional_plugins += [:Passwd]
EOF

sudo openssl genrsa -out /etc/cinc/client-prod.pem
sudo openssl genrsa -out /etc/cinc/validation.pem

sudo ln -sf /etc/cinc/client-prod.rb /etc/chef/client.rb
sudo ln -sf /etc/cinc/client-prod.pem /etc/chef/client.pem

sudo tee /etc/chef/chefctl_hooks.rb <<EOF
EOF

sudo tee /etc/chefctl-config.rb <<EOF
chef_client '/opt/cinc/bin/cinc-client'
chef_options ['--no-fork']
log_dir '/var/log/chef'
EOF

sudo tee /etc/chef/run-list.json <<EOF
{
  "run_list" : [
    "recipe[boxcutter_ohai]",
    "recipe[boxcutter_init]"
  ]
}
EOF

sudo mkdir -p /var/chef /var/chef/repos /var/log/chef
cd /var/chef/repos
sudo git clone https://github.com/boxcutter/chef-cookbooks.git \
  /var/chef/repos/chef-cookbooks
sudo git clone https://github.com/boxcutter/boxcutter-chef-cookbooks.git \
  /var/chef/repos/boxcutter-chef-cookbooks

sudo mkdir -p /usr/local/sbin
sudo curl -o /usr/local/sbin/chefctl.rb https://raw.githubusercontent.com/facebook/chef-utils/main/chefctl/src/chefctl.rb
sudo chmod +x /usr/local/sbin/chefctl.rb
sudo ln -sf /usr/local/sbin/chefctl.rb /usr/local/sbin/chefctl

sudo touch /root/firstboot_os
echo "{\"tier\": \"robot\"}" | sudo tee /etc/boxcutter-config.json > /dev/null
sudo /usr/local/sbin/chefctl -iv

# Behind the scenes, it'sdoing this:
# /opt/cinc/bin/cinc-client -c /etc/cinc/client.rb -j /etc/chef/run-list.json
# /opt/cinc/bin/cinc-client --config /etc/cinc/client.rb --json-attributes /etc/chef/run-list.json
```

Ubuntu NVIDIA Jetson
--------------------

### Spin up Ubuntu 20.04 arm64 cloud image as a VM

```
curl -LO https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-arm64.img

$ qemu-img info focal-server-cloudimg-arm64.img
image: focal-server-cloudimg-arm64.img
file format: qcow2
virtual size: 2.2 GiB (2361393152 bytes)
disk size: 571 MiB
cluster_size: 65536
Format specific information:
    compat: 0.10
    refcount bits: 16

sudo qemu-img convert \
  -f qcow2 \
  -O qcow2 \
  focal-server-cloudimg-arm64.img \
  /var/lib/libvirt/images/ubuntu-server-2004.qcow2
sudo qemu-img resize \
  -f qcow2 \
  /var/lib/libvirt/images/ubuntu-server-2004.qcow2 \
  32G
```

```
touch network-config

cat >meta-data <<EOF
instance-id: ubuntu-server-2004
local-hostname: ubuntu-server-2004
EOF

cat >user-data <<EOF
#cloud-config
password: superseekret
chpasswd:
  expire: False
ssh_pwauth: True
EOF
```

```
sudo apt-get update
sudo apt-get install genisoimage
#     -input-charset utf-8 \
genisoimage \
    -input-charset utf-8 \
    -output ubuntu-server-2004-cloud-init.img \
    -volid cidata -rational-rock -joliet \
    user-data meta-data network-config
sudo cp ubuntu-server-2004-cloud-init.img /var/lib/libvirt/boot/ubuntu-server-2004-cloud-init.iso
```

```
virt-install \
  --connect qemu:///system \
  --name ubuntu-server-2004 \
  --boot uefi \
  --memory 4096 \
  --vcpus 2 \
  --os-variant ubuntu20.04 \
  --disk /var/lib/libvirt/images/ubuntu-server-2004.qcow2,bus=virtio \
  --disk /var/lib/libvirt/boot/ubuntu-server-2004-cloud-init.iso,device=cdrom \
  --network network=host-network,model=virtio \
  --noautoconsole \
  --console pty,target_type=serial \
  --import \
  --debug

virsh console ubuntu-server-2204

# login with ubuntu user
$ cloud-init status
status: done

# Disable cloud-init
$ sudo touch /etc/cloud/cloud-init.disabled

$ cloud-init status
status: disabled

$ sudo shutdown -h now
```

```
$ virsh domblklist ubuntu-server-2004
 Target   Source
-------------------------------------------------------------------
 vda      /var/lib/libvirt/images/ubuntu-server-2004.qcow2
 sda      /var/lib/libvirt/boot/ubuntu-server-2004-cloud-init.iso

$ virsh change-media ubuntu-server-2004 sda --eject
Successfully ejected media.

$ sudo rm /var/lib/libvirt/boot/ubuntu-server-2004-cloud-init.iso
$ virsh edit ubuntu-server-2004
# remove entry for the cloud-init.iso
<!--
    <disk type='file' device='cdrom'>
      <driver name='qemu' type='raw'/>
      <source file='/var/lib/libvirt/boot/ubuntu-server-2204-cloud-init.iso'/>
      <target dev='sda' bus='sata'/>
      <readonly/>
      <address type='drive' controller='0' bus='0' target='0' unit='0'/>
    </disk>
-->

$ virsh snapshot-create-as --domain ubuntu-server-2004 --name clean --description "Initial install"
error: Operation not supported: internal snapshots of a VM with pflash based firmware are not supported

# Nameless snapshot
virsh snapshot-create ubuntu-server-2004
virsh snapshot-list ubuntu-server-2004
virsh snapshot-revert ubuntu-server-2004 clean
virsh snapshot-delete ubuntu-server-2004 clean

virsh destroy ubuntu-server-2404
virsh undefine ubuntu-server-2004 --nvram --remove-all-storage
```

Install 1Password CLI
---------------------

```
apt-get update
apt-get install unzip
# ARCH="<choose between 386/amd64/arm/arm64>"
wget "https://cache.agilebits.com/dist/1P/op2/pkg/v2.29.0/op_linux_amd64_v2.29.0.zip" -O op.zip
unzip -d op op.zip
sudo mv op/op /usr/local/bin/
rm -r op.zip op
sudo groupadd -f onepassword-cli
sudo chgrp onepassword-cli /usr/local/bin/op
sudo chmod g+s /usr/local/bin/op
```

Install cinc-client and chefctl
-------------------------------

```
# chefctl uses a shebang that points at /opt/chef, so make sure we have a link
# in place for compatibility
sudo mkdir -p /etc/cinc
# -n must be here in case /etc/chef already exists, otherwise
# it tries to create /etc/chef/cinc
# /etc/chef -> /etc/cinc
sudo ln -snf /etc/cinc /etc/chef

curl -L https://omnitruck.cinc.sh/install.sh | sudo bash

# /opt/chef -> /opt/cinc
sudo ln -snf /opt/cinc /opt/chef

sudo tee /etc/cinc/client-prod.rb <<EOF
local_mode true
chef_repo_path '/var/chef/repos/boxcutter-chef-cookbooks'
cookbook_path ['/var/chef/repos/chef-cookbooks/cookbooks', '/var/chef/repos/boxcutter-chef-cookbooks/cookbooks']
follow_client_key_symlink true
client_fork false
no_lazy_load false
local_key_generation true
json_attribs '/etc/cinc/run-list.json'
ohai.critical_plugins ||= []
ohai.critical_plugins += [:Passwd]
ohai.optional_plugins ||= []
ohai.optional_plugins += [:Passwd]
EOF

sudo openssl genrsa -out /etc/cinc/client-prod.pem
sudo openssl genrsa -out /etc/cinc/validation.pem

sudo rm -f /etc/cinc/client.rb
sudo ln -sf /etc/cinc/client-prod.rb /etc/chef/client.rb
sudo ln -sf /etc/cinc/client-prod.pem /etc/chef/client.pem

# sudo tee /etc/chef/chefctl_hooks.rb <<EOF
# EOF

sudo tee /etc/chefctl-config.rb <<EOF
chef_client '/opt/cinc/bin/cinc-client'
chef_options ['--no-fork']
log_dir '/var/log/chef'
EOF

sudo tee /etc/chef/run-list.json <<EOF
{
  "run_list" : [
    "recipe[boxcutter_ohai]",
    "recipe[boxcutter_init]"
  ]
}
EOF

sudo mkdir -p /var/chef /var/chef/repos /var/log/chef
sudo su -
cd /var/chef/repos
sudo git clone https://github.com/boxcutter/chef-cookbooks.git
sudo git clone https://github.com/boxcutter/boxcutter-chef-cookbooks.git

sudo mkdir -p /usr/local/sbin
sudo curl -o /usr/local/sbin/chefctl.rb https://raw.githubusercontent.com/facebook/chef-utils/main/chefctl/src/chefctl.rb
sudo chmod +x /usr/local/sbin/chefctl.rb
sudo ln -sf /usr/local/sbin/chefctl.rb /usr/local/sbin/chefctl

sudo touch /root/firstboot_os
echo "{\"tier\": \"robot\"}" > /etc/boxcutter-config.json
sudo chefctl -iv

/opt/cinc/bin/cinc-client -c /etc/cinc/client.rb -j /etc/chef/run-list.json
/opt/cinc/bin/cinc-client --config /etc/cinc/client.rb --json-attributes /etc/chef/run-list.json
```
