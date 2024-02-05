# boxcutter-chef-cookbooks [![boxcutter-chef-cookbooks](https://github.com/boxcutter/boxcutter-chef-cookbooks/actions/workflows/ci.yml/badge.svg)](https://github.com/boxcutter/boxcutter-chef-cookbooks/actions/workflows/ci.yml)

This repo contains automation used to maintain a fleet of robots using
neuromorphic sensors and their supporting infrastructure. It is built
on top of the attribute-driven API cookbooks maintained by
Meta/Facebook. For more information about this style of writing automation
code, refer to the [Facebook Cookbooks Suite README](https://github.com/facebook/chef-cookbooks/blob/main/README.md).

To use these cookbooks, make sure that `boxcutter_ohai` and `boxcutter_init`
cookbooks are first in the Chef run-list, then followed by whatever
cookbooks you need for your config. The first two cookbooks in the run-list
set up all the automatic and global attribute defaults used in the
automation.

```ruby
"recipe[boxcutter_ohai],recipe[boxcutter_init],..."
```

 Also make sure that all the cookbooks in Facebook's `chef-cookbooks`
and this `boxcutter-chef-cookbooks` are in the cookbook path:

```ruby
cookbook_path [ 'ssh://git@github.com:facebook/chef-cookbooks.git',
                'ssh://git@github.com:boxcutter/boxcutter-chef-cookbooks.git' ]
```
