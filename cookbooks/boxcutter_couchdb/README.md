boxcutter_couchdb
=================

Configures the Apache CouchDB document-oriented database.

Usage
-----

This automation defaults to configuring a single node install of CouchDB.

First, you'll need to define an admin username and password that Chef will use
to drive the automation. Since this is a secret, it is recommended that these
credentials be stored in the `node.run_state` so that sensitive information
is not stored on a Chef Server after the Chef run.

The automation will look for credentials in the following preference order

```
1. `node.run_state['boxcutter_couchdb']['admin_username']`
   `node.run_state['boxcutter_couchdb']['admin_password']`
2. `node['boxcutter_couchdb']['admin_username']`
   `node['boxcutter_couchdb']['admin_password']`
```

Before you reference the `boxcutter_couchdb` cookbook, make sure to initialize
the admin credentials in `node.run_state`. Normally you would populate these
values from your secret store and not provide them directly as string literals
in this example.

```ruby
# Initialize the parent hash if it doesn't exist
node.run_state['boxcutter_couchdb'] ||= {}
node.run_state['boxcutter_couchdb']['admin_username'] = 'admin'
node.run_state['boxcutter_couchdb']['admin_password'] = 'superseekret'

include_recipe 'boxcutter_couchdb::default'
```
