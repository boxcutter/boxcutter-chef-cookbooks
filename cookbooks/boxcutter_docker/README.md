# boxcutter_docker

Configure the Docker daemon and containers.

## Attributes

- node['boxcutter_docker']['enable']
- node['boxcutter_docker']['group']
- node['boxcutter_docker']['config']
- node['boxcutter_docker']['buildx']
- node['boxcutter_docker']['containers']
- node['boxcutter_docker']['bind_mounts']
- node['boxcutter_docker']['volumes']
- node['boxcutter_docker']['networks']

## Usage

### enable

Boolean determining whether or not the docker service is enabled. Defaults to
true.

### group

Defines the group name to be used for the docker group. Defaults to `docker`.
The group GID must will be defined in the GID map configured in `boxcutter_users`.

To add users to docker group, append to the array
`node['fb_users']['groups']['docker']['members']`:

````aiignore
node.default['fb_users']['groups']['docker']['members'] << 'alice'
````

If you change the default docker group name, just change the docker group name
accordingly.

### config

The `config` hash configures the contents of `/etc/docker/daemon.json`. The
hash is converted to JSON. Changing the config will restart the docker service.

### buildx

You can use the `buildx` attribute to manage Moby BuildKit builder instances.
Builder instances are isolated container environments where builds can be
invoked.

Using this attribute requires more setup, because the `buildx` commands we
rely on to implement this automation require a user account to run under.
Unlike the rest of the attribute implementations currently, which are system-wide.
Refer to the examples below:

```
node['boxcutter_docker']['buildx']['craft'] = {
  'home' => '/home/craft',
  'user' => 'craft',
  'group' => 'craft',
  'builders' => {
    'mybuilder' => {
      'name' => 'mybuilder',
      'use' => true,
    }
  }
}
```

```
$ docker buildx ls
NAME/NODE        DRIVER/ENDPOINT                   STATUS     BUILDKIT   PLATFORMS
mybuilder*       docker-container
 \_ mybuilder0    \_ unix:///var/run/docker.sock   inactive
default          docker
 \_ default       \_ default                       running    v0.16.0    linux/arm64
```

```
cat >Containerfile <<EOF
FROM ubuntu:22.04

RUN apt-get update
RUN apt-get install -y figlet
EOF

cat >docker-bake.hcl <<EOF
target "default" {
  tags = ["docker.io/boxcutter/testy"]
  dockerfile = "Containerfile"
}
EOF

$ docker buildx bake
```

```
node['boxcutter_docker']['buildx']['craft'] = {
  'home' => '/home/craft',
  'user' => 'craft',
  'group' => 'craft',
  'builders' => {
    'multi-arch-builder' => {
      'name' => 'multi-arch-builder',
      'use' => true,
    }
  }
}
```

### containers

Configures all the containers on the system. Any unknown containers will be
stopped and removed.

### bind_mounts

If you want to bind mount a directory that is configured with Chef, doing that
configuration with a `directory` resource a user cookbook is too late in the
run list. Likely the `docker` cookbook will have started the container before
the directory is create. The `bind_mounts` attribute contains of list of
directories to configure. Entries in the hash are the same as the `directory`
resource. `owner`, `group` and `mode` keys are required. If the `path` isn't
specified the name of the hash is used.

```aiignore
node.default['boxcutter_docker']['bind_mounts']['nexus_data'] = {
  'path' => '/opt/sonatype/sonatype-work/nexus-data',
  'owner' => 200,
  'group' => 200,
  'mode' => '0755',
}
```

If you remove entries from this attribute, this cookbook won't try to do any
automatic cleanup of the directory itself. This should be done in a user
cookbook.

### volumes

The `volumes` hash will configure volumes that containers can consume and
store data.

```
node.default['boxcutter_docker']['volumes']['postgres_data'] = {
  'name' => 'postgres-data',
}
```

If the `name` attribute isn't provided, the name of the hash is used:

```
node.default['boxcutter_docker']['volumes']['prometheus_data'] = {}
```

### networks

Configure networks for containers to use.

```
node.default['boxcutter_docker']['networks']['monitoring'] = {
  'name' => 'metrics',
}
```

If the `name` attribute isn't provided, the name of the has is used:

```
node.default['boxcutter_docker']['networks']['monitoring'] = {}
```
