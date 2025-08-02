boxcutter_nfs
=============

Configures NFS servers and clients.

Usage
-----

### Server

The `boxcutter_nfs::server` recipe will configure an NFS server and make a list
of directories available to clients.

`node['boxcutter_nfs']['server']['exports']` is a value:array pair of 
containing a list of directories on the NFS server to make available to NFS
clients.

### Client

The `boxcutter_nfs::client` recipe will configure a host as an NFS client so
it cant mount NFS shares.

`node['boxcutter_nfs']['idmap']` manages `/etc/idmapd.conf` for NFSv4
id <-> name mapping. The documentation implies sections and options in this
file are case-sensitive, but they're not. We use all lower-case for these
values.

References:

Ubuntu: https://ubuntu.com/server/docs/network-file-system-nfs

RedHat: https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/managing_file_systems/deploying-an-nfs-server_managing-file-systems#configuring-an-nfsv4-only-server_deploying-an-nfs-server
