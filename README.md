boxcutter-chef-cookbooks
========================

[![Continuous Integration](https://github.com/boxcutter/boxcutter-chef-cookbooks/actions/workflows/ci.yml/badge.svg)](https://github.com/boxcutter/boxcutter-chef-cookbooks/actions/workflows/ci.yml)
[![Kitchen Tests](https://github.com/boxcutter/boxcutter-chef-cookbooks/actions/workflows/kitchen.yml/badge.svg)](https://github.com/boxcutter/boxcutter-chef-cookbooks/actions/workflows/kitchen.yml)

This repo contains automation used to configure a fleet of robots using
neuromorphic sensors and their supporting infrastructure. The code in this
repo follows the [Meta/Facebook attribute-driven API](https://github.com/facebook/chef-cookbooks)
model. None of this code is maintained by Meta.

For more information about this style of writing automation
code, refer to the [**Phil**osophy,](https://github.com/facebook/chef-utils/blob/main/Philosophy.md)
[Facebook Cookbooks Suite README](https://github.com/facebook/chef-cookbooks/blob/main/README.md)
and [Compile Time vs Run Time, and APIs](https://github.com/facebook/chef-utils/blob/main/Compile-Time-Run-Time.md).

You may also find the following videos from Phil Dibowitz helpful:

**[Watch: Scaling System Configuration at Facebook (41 mins)](https://www.youtube.com/watch?v=-YtZiVxEiJ8)**  

[![Watch Scaling System Configuration at Facebook](https://img.youtube.com/vi/-YtZiVxEiJ8/0.jpg)](https://www.youtube.com/watch?v=-YtZiVxEiJ8)

**[Watch: The Softer Side of DevOps (46 mins)](https://www.youtube.com/watch?v=ry51Llzil1I)**  

[![Watch The Softer Side of DevOps](https://img.youtube.com/vi/ry51Llzil1I/0.jpg)](https://www.youtube.com/watch?v=ry51Llzil1I)

The primary maintainer of this repo, Mischa Taylor, is also working on some
[training](https://taylorific.github.io/chef-training) on Meta-style API
coding.

Attributions
------------
- [@jaymzh](https://github.com/jaymzh) for open sourcing https://github.com/socallinuxexpo/scale-chef
  which has a great example for automating `chefctl` (among other things)
- [@jaymzh](https://www.phildev.net/) and
  [@bwann](https://binaryfury.wann.net/) for showing me the Facebook Chef way
