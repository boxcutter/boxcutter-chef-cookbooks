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
Builder instances are isolated environments where builds can be invoked.

```
node['boxcutter_docker']['buildx']['mybuilder'] = {
  'home' => '/home/craft',
  'user' => 'craft',
  'group' => 'craft',
  'builders' => {
    'mybuilder' => {
      'name' => 'mybuilder',
      'driver' => 'docker',
      'use' => true,
    }
  }
}
```
