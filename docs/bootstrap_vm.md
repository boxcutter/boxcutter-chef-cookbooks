# Bootstrapping Chef

## Ubuntu

## Spin up Ubuntu 22.04 cloud image as a VM

```
curl -LO https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img

$ qemu-img info jammy-server-cloudimg-amd64.img 
image: jammy-server-cloudimg-amd64.img
file format: qcow2
virtual size: 2.2 GiB (2361393152 bytes)
disk size: 620 MiB
cluster_size: 65536
Format specific information:
    compat: 0.10
    compression type: zlib
    refcount bits: 16

sudo qemu-img convert \
  -f qcow2 \
  -O qcow2 \
  jammy-server-cloudimg-amd64.img \
  /var/lib/libvirt/images/ubuntu-server-2204.qcow2
sudo qemu-img resize \
  -f qcow2 \
  /var/lib/libvirt/images/ubuntu-server-2204.qcow2 \
  32G
```

```
touch network-config

cat >meta-data <<EOF
instance-id: ubuntu-server-2204
local-hostname: ubuntu-server-2204
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
    -output ubuntu-server-2204-cloud-init.img \
    -volid cidata -rational-rock -joliet \
    user-data meta-data network-config
sudo cp ubuntu-server-2204-cloud-init.img /var/lib/libvirt/boot/ubuntu-server-2204-cloud-init.iso
```

```
virt-install \
  --connect qemu:///system \
  --name ubuntu-server-2204 \
  --boot uefi \
  --memory 4096 \
  --vcpus 2 \
  --os-variant ubuntu22.04 \
  --disk /var/lib/libvirt/images/ubuntu-server-2204.qcow2,bus=virtio \
  --disk /var/lib/libvirt/boot/ubuntu-server-2204-cloud-init.iso,device=cdrom \
  --network network=host-network,model=virtio \
  --graphics spice \
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
$ virsh domblklist ubuntu-server-2204
 Target   Source
-------------------------------------------------------------------
 vda      /var/lib/libvirt/images/ubuntu-server-2204.qcow2
 sda      /var/lib/libvirt/boot/ubuntu-server-2204-cloud-init.iso

$ virsh change-media ubuntu-server-2204 sda --eject
Successfully ejected media.

$ sudo rm /var/lib/libvirt/boot/ubuntu-server-2204-cloud-init.iso
$ virsh edit ubuntu-server-2204
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

virsh snapshot-create-as --domain ubuntu-server-2204 --name clean --description "Initial install"

# Nameless snapshot
virsh snapshot-create ubuntu-server-2204
virsh snapshot-list ubuntu-server-2204
virsh snapshot-revert ubuntu-server-2204 clean
virsh snapshot-delete ubuntu-server-2204 clean

virsh destroy ubuntu-server-2404
virsh undefine ubuntu-server-2404 --nvram --remove-all-storage
```

## Install cinc-client and chefctl

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

## CentOS

```
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
  32G
```

```
touch network-config

cat >meta-data <<EOF
instance-id: centos-stream-9
local-hostname: centos-stream-9
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
genisoimage \
    -input-charset utf-8 \
    -output centos-stream-9-cloud-init.img \
    -volid cidata -rational-rock -joliet \
    user-data meta-data network-config
sudo cp centos-stream-9-cloud-init.img /var/lib/libvirt/boot/centos-stream-9-cloud-init.iso
```

```
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

virsh console centos-stream-9

# cloud-user / superseekret
ssh cloud-user@localhost -p 2222

# login with cloud-user

# Check networking - you may notice that the network interface is down and
# the name of the interface generated in netplan doesn't match. If not
# correct, can regenerate with cloud-init
# ip reports that enp1s0 is down
$ ip --brief a
lo               UNKNOWN        127.0.0.1/8 ::1/128 
eth0             UP             10.63.44.89/22 fe80::ea9d:34f2:68cc:bc78/64

# Check cloud-init version
$ cloud-init --version
/usr/bin/cl
oud-init
23.4-11.el9

# Regenerate only the network config
$ sudo cloud-init clean --configs network
$ sudo cloud-init init --local

$ sudo reboot

$ ip --brief a
lo               UNKNOWN        127.0.0.1/8 ::1/128 
eth0             UP             10.63.44.89/22 fe80::5054:ff:fe12:a922/64

# Check cloud-init status
$ sudo cloud-init status
status: done

# Disable cloud-init
$ sudo touch /etc/cloud/cloud-init.disabled

# Verify cloud-init is disabled
$ sudo cloud-init status
status: disabled

$ sudo shutdown -h now
```

```
$ virsh domblklist centos-stream-9
 Target   Source
----------------------------------------------------------------
 vda      /var/lib/libvirt/images/centos-stream-9.qcow2
 sda      /var/lib/libvirt/boot/centos-stream-9-cloud-init.iso

$ virsh change-media centos-stream-9 sda --eject
Successfully ejected media.

$ sudo rm /var/lib/libvirt/boot/centos-stream-9-cloud-init.iso
```

```
$ virsh shutdown centos-stream-9
$ virsh undefine centos-stream-9 --nvram --remove-all-storage

# Snapshots
# Named snapshot
virsh snapshot-create-as --domain centos-stream-9 --name clean --description "Initial install"
# Nameless snapshot
virsh snapshot-create centos-stream-9
virsh snapshot-list centos-stream-9
virsh snapshot-revert centos-stream-9 <name>
virsh snapshot-delete centos-stream-9 <name>
```

```
docker container run --rm --interactive --tty \
  --mount type=bind,source="$(pwd)",target=/share \
  docker.io/boxcutter/cinc-auditor exec cinc-client \
    --password superseekret \
    --target ssh://cloud-user@10.63.46.148
```

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
    "boxcutter_init::default"
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

