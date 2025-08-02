boxcutter_users
===============

Populates the UID_MAP and GID_MAP for the `fb_users` cookbook.

Description
-----------

Per [fb_users](https://github.com/facebook/chef-cookbooks/blob/main/cookbooks/fb_users/README.md)
this cookbook provides the consistent data that should never change describing
user accounts and groups via the `UID_MAP` and `GID_MAP`.

To ensure the data is never changed, rather than using node attributes, this
data is defined by re-opening the `FB::Users` class. This is just used as
a source of data for other automation to refer to users and groups consistently.
No code in this cookbook actually creates user accounts and groups.

This is a support cookbook used by `boxcutter_init` and should not be called
directly by other cookbooks besides sometimes other support cookbooks.
The `boxcutter_init` cookbook uses `fb_users` to manage users and groups on
systems, and it errors if the `UID_MAP` and `GID_MAP` aren't defined.

We move this code related to the data definition out to a separate cookbook
from `boxcutter_init` so it can be more easily tested in isolation.
