# boxcutter_docker

Configure the Docker daemon and containers.

## Attributes

- node['boxcutter_docker']['enable']
- node['boxcutter_docker']['group']
- node['boxcutter_docker']['config']
- node['boxcutter_docker']['buildkits']
- node['boxcutter_docker']['contexts']
- node['boxcutter_docker']['containers']
- node['boxcutter_docker']['bind_mounts']
- node['boxcutter_docker']['volumes']
- node['boxcutter_docker']['devices']
- node['boxcutter_docker']['networks']

## Usage

### BuildKit

You can use the `contexts` attribute to define connections to other Docker
daemons.

The following example will create a new context called `docker-test` and specifies the
host endpoint of the context to TCP socket `tcp://docker:2375`.

```
node['boxcutter_docker']['contexts']['docker-test'] = {
  'docker' => 'host=tcp://docker:2375'
}
```

You can use the `buildkits` attribute to manage dedicated BuildKit containers
using Docker. These dedicated BuildKit containers are needed for multi-platform
builds because the default [docker driver](https://docs.docker.com/build/drivers/docker/)
does not support building multiple platforms with `docker buildx build`

```
node['boxcutter_docker']['buildkits']['x86_64_builder'] = {
  'name' => 'x86-64-builder',
  'use' => true,
}
```

```
node['boxcutter_docker']['contexts']['docker-test'] = {
  'docker' => 'host=ssh://user@remote_host',
  'description' => 'My Remote Docker Host'
}
node['boxcutter_docker']['contexts']['context1'] = {
  'name' => 'foo',
  'docker' => 'host=ssh://user@remote_host',
  'description' => 'My Remote Docker Host'
}
```
