boxcutter_ohai
==============

Installs ohai plugins that set the highest-precedence automatic defaults used
by all other cookbooks in this hierarchy.

Description
-----------

This is a support cookbook intended to used along with the `boxcutter_init`
cookbook to set global defaults. This cookbook is placed first in the run list
on any machine to install ohai plugins that set automatic attributes, as a
"pre-hook" to `boxcutter_init`. It is not intended to be used directly by any
other cookbook.

Because of the way attribute precedence works in Chef, this cookbook needs
to be the very first cookbook in the runlist, before `boxcutter_init`. It
will install any ohai plugins needed that set defaults at the very highest
level of precedence in Chef, the automatic level.

This isn't a recipe in the `boxcutter_init` cookbook as Chef loads files
that contain attributes in `a-z` lexicographic order, so then you have to
do all sorts of shenanigans in the "init" cookbook to make sure the code
is called first. It's easier to just break out the code that needs to set
automatic variables and install ohai plugins to be a separate cookbook that
is first in the runlist. Then you know this code is always called first,
before anything else.
