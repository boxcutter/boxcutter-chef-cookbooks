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
- node['boxcutter_docker']['devices']
- node['boxcutter_docker']['networks']

## Usage

### BuildKit

You can use the `buildx` attributes to manage Moby BuildKit builder instances.
Builder instances are isolated container environments where builds can be
invoked.

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
    'mybuilder' => {
      'name' => 'mybuilder',
      'use' => true,
    }
  }
}
```
