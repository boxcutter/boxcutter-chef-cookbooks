boxcutter-chef-cookbooks [![boxcutter-chef-cookbooks](https://github.com/boxcutter/boxcutter-chef-cookbooks/actions/workflows/ci.yml/badge.svg)](https://github.com/boxcutter/boxcutter-chef-cookbooks/actions/workflows/ci.yml)
========================

This  repo contains automation used to maintain a fleet of robots using
neuromorphic sensors and their supporting infrastructure. It is built
on top of the attribute-driven API cookbooks maintained by
Meta/Facebook. For more information about this style of writing automation
code, refer to the [Philosophy](https://github.com/facebook/chef-utils/blob/main/Philosophy.md)
,[Facebook Cookbooks Suite README](https://github.com/facebook/chef-cookbooks/blob/main/README.md)
and [Compile Time vs Run Time, and APIs](https://github.com/facebook/chef-utils/blob/main/Compile-Time-Run-Time.md).

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

For the most part we use the `kitchen-dokken` driver, as it is by far the
fastest Test kitchen driver. In some instances, we also use the
`kitchen-digitalocean` and `kitchen-aws` drivers to test automation that
can't run inside Docker, like the Docker automation itself or automation
involving running Docker containers.

For [kitchen-digitalocean](https://kitchen.ci/docs/drivers/digitalocean/):

```aiignore
export DIGITALOCEAN_ACCESS_TOKEN=<do_access_token>

curl \
  -X GET https://api.digitalocean.com/v2/account/keys \
  -H "Authorization: Bearer $DIGITALOCEAN_ACCESS_TOKEN"

export KITCHEN_YAML=kitchen_digitalocean.yml
export DIGITALOCEAN_SSH_KEY_IDS=41887654,41887653
```

Attributions
------------
- [@jaymzh](https://github.com/jaymzh) for open sourcing https://github.com/socallinuxexpo/scale-chef
  which has a great example for automating `chefctl` (among other things)
- [@jaymzh](https://www.phildev.net/) and
  [@bwann](https://binaryfury.wann.net/) for showing me the Facebook Chef way
