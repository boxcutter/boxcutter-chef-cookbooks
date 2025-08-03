boxcutter_postgresql
====================

PostgreSQL is a free, open-source relational database system that stores,
manages, and retrieves structured data.

- It uses Structure Query Language (SQL) to interact with data.
- It supports complex queries, transactions, data integrity and concurrency
  extremely well.
- It is licensed under a very permissive **PostgreSQL License** (similar to
  MIT).

Usage
-----

By default, this cookbook installs PostgreSQL 16 and ensures
that the postgres server is enabled and set to restart on boot.

You can use the `enable` attribute to control the running status of the
postgres service. You can also manage the data directory configuration
and the client configuration through node attributes.

Future versions of this cookbook may add more options to configure
databases themselves.

Terminology Differences
-----------------------

### Cluster vs. Instance

### Role vs. User

### Data directory configuration

Use `node['boxcutter_postgresql']['server']['config']` to control the
parameters specified in the `postgresql.conf` for the data directory.

### Client configuration

Use `node['boxcutter_postgresql']['server']['pg_hba']` to automate
configuring of the `pg_hba.conf` file, that controls client configuration.

Resources
---------

There are a few supporting resources that are used to encapsulate "update"
functionality used in the "configuration as data" implementation on various
PostgreSQL objects:

### `boxcutter_postgresql_role`

The `boxcutter_postgresql_reole` resource configures a PostgreSQL role.
There is only one type of authetnicational principal in PostgreSQL, a `ROLE`.
By convention, a `ROLE` that allows login is considered a **user**, while a
role that is not allowed to login is a **group**. (While there are
`CREATE USER` and `CREATE GROUP` commands, they are aliases for `CREATE ROLE`).

```ruby
boxcutter_postgresql_role 'dev1'
```

#### Actions

- `:create` - Define a new database role. *(default)*
- `:alter` - Change a database role.
- `:drop` - Remove a database role.

Attributions
------------
Thanks to Lance Albertson (@ramereth), Jason Field (@xorima) and the
Sous Chefs (@sous-chefs) for their [PostgreSQL cookbook](https://github.com/sous-chefs/postgresql)
Some of the code from Sous Chefs was adapted to the Meta/Facebook
API style in this cookbook.
