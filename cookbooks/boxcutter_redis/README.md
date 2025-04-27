# boxcutter_redis

Redis (**RE**mote **DI**ctionary **S**erver) is an open source, in-memory,
NoSQL key/value store that is primarily used as an application cache or
quick-response database.

## Attributes 

- node['boxcutter_redis']['enable']

## Usage

By default, this cookbook installs the `redis-server` package and ensures
that the redis service is enabled and set to restart on boot.

You can use the `enable` attribute to control the running status of the
redis service.

This cookbook currently **does not** manage the Redis configuration file
(`redis.conf`). Redis will run with the default settings installed by the
platform's package manager.

Future versions of this cookbook may add more configuration management
options.

If you need to manage custom Redis settings today, you should manually
manage `/etc/redis/redis.conf` outside of this cookbook, or extend it as
needed.

