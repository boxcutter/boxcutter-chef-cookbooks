boxcutter_docker
================

Configure the Docker daemon and containers.

Attributes
----------

- node['boxcutter_docker']['enable']
- node['boxcutter_docker']['group']
- node['boxcutter_docker']['config']
- node['boxcutter_docker']['buildx']
- node['boxcutter_docker']['containers']
- node['boxcutter_docker']['bind_mounts']
- node['boxcutter_docker']['volumes']
- node['boxcutter_docker']['networks']

Usage
-----

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

Runs containers in detached mode. Any unlisted containers will be stopped and
removed. The following options are supported as keys in the hash:

- `image` - docker image name to use in order to create the running container
- `name` - specify a custom identifier for a container. If the name is not
  specified, the key value name of the container hash is used.
- `environment` - set simple (non-array) environment variables in the
  container with the `--env` flag.
- `ports` - ports to publish/expose with the `--expose` flag.
- `mounts` - mount volumes, host-directories or tmpfs volumes in a container
  using the `--mount` flag.
- `ulimits` - set ulumit settings using the `--ulimit` flag.
- `log_opts` - specify log driver options using the `log-opt` flag.
- `extra_options` - specify additional options supported by the
  `docker container run` command not supported with predefined keys.
- `action` action to perform on the container, defaults to `run`:
    - `run` - the default action, creates and starts the container
    - `stop` - stops the container
    - `start` - starts the container

```aiignore
node.default['boxcutter_docker']['volumes']['postgres_data'] = {}

node.default['boxcutter_docker']['containers']['postgresql'] = {
  'image' => 'releases-docker.jfrog.io/postgres:15.6-alpine',
  'environment' => {
    'POSTGRES_DB' => 'artifactory',
    'POSTGRES_USER' => 'artifactory',
    'POSTGRES_PASSWORD' => 'superseekret',
  },
  'ports' => {
    '5432' => '5432',
  },
  'mounts' => {
    'postgres_data' => {
      'source' => 'postgres_data',
      'target' => '/var/lib/postgresql/data',
    },
    'localtime' => {
      'type' => 'bind',
      'source' => '/etc/localtime',
      'target' => '/etc/localtime:ro',
    },
  },
  'ulimits' => {
    'nproc' => '65535',
    'nofile' => '32000:40000',
  },
  'logging_options' => {
    'max-size' => '50m',
    'max-file' => '10',
  },
  'extra_options' => {
    'restart' => 'always',
    'log-driver' => 'json-file',
    'network' => 'artifactory_network',
  },
}
```

### bind_mounts

If you want to bind mount a directory or file that is configured with Chef,
doing that configuration with a `directory` or `file` resource a user cookbook
is too late in the run list. Likely the `docker` cookbook will have started
the container before the directory/file is created. The `bind_mounts` attribute
contains of list of directories/files to configure. Entries in the hash are the
same as the `directory` or `file` resource. `owner`, `group` and `mode` keys
are required. If the `path` isn't specified the name of the hash is used.

```aiignore
node.default['boxcutter_docker']['bind_mounts']['nexus_data'] = {
  'path' => '/opt/sonatype/sonatype-work/nexus-data',
  'owner' => 200,
  'group' => 200,
  'mode' => '0755',
}

node.default['boxcutter_docker']['bind_mounts']['onepassword_credentials'] = {
  'type' => 'file',
  'path' => '/home/opuser/.op/1password-credentials.json',
  'owner' => 999,
  'group' => 999,
  'content' => json_content,
  'mode' => '0600',
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
