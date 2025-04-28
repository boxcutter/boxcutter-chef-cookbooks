# boxcutter_redis

Redis (**RE**mote **DI**ctionary **S**erver) is an open source, in-memory,
NoSQL key/value store that is primarily used as an application cache or
quick-response database.

## Attributes 

- node['boxcutter_redis']['enable']
- node['boxcutter_redis']['config']

## Usage

By default, this cookbook installs the `redis-server` package and ensures
that the redis service is enabled and set to restart on boot.

You can use the `enable` attribute to control the running status of the
redis service.

The `config` attribute can be used to manage the Redis configuration file
`/etc/redis/redis.conf`.
