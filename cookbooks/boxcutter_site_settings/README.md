boxcutter_site_settings
=======================

Site settings for Boxcutter.

Description
-----------

Sets up all the global default settings, which the Meta Chef automation refers
to as "site settings". These can be overridden at any level in other cookbooks,
per the attribute-driven hierarchy used in the automation scheme used in this
set of cookbooks.

This cookbook is not intended to be used directly. It just contains some
supporting code that is consumed by the `boxcutter_init` cookbook.

This cookbook is called very early in the Chef automation run via
`boxcutter_init::site_settings` to set up all these defaults.

These "site settings" have been moved out to a dedicated cookbook so that they
can be tested in isolation, as these default settings can have complicated
logic to test. Also this separation makes it easier to swap out a different set
of defaults as needed for different use cases.
