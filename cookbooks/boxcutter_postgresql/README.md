# boxcutter_postgresql

PostgreSQL is a free, open-source relational database system that stores,
manages, and retrieves structured data.

- It uses Structure Query Language (SQL) to interact with data.
- It supports complex queries, transactions, data integrity and concurrency
  extremely well.
- It is licensed under a very permissive **PostgreSQL License** (similar to
  MIT).

## Usage

By default, this cookbook installs PostgreSQL 16 and ensures
that the postgres server is enabled and set to restart on boot.

You can use the `enable` attribute to control the running status of the
postgres service. You can also manage the data directory configuration
and the client configuration through node attributes.

Future versions of this cookbook may add more options to configure
databases themselves.

### Data directory configuration

Use `node['boxcutter_postgresql']['server']['config']` to control the
parameters specified in the `postgresql.conf` for the data directory.

### Client configuration

Use `node['boxcutter_postgresql']['server']['pg_hba']` to automate
configuring of the `pg_hba.conf` file, that controls client configuration.

