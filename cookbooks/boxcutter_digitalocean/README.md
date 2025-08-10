boxcutter_digitalocean
======================

Configures DigitalOcean agents.

Attributes
----------

* node['boxcutter_digitalocean']['droplet_agent']['enable']
* node['boxcutter_digitalocean']['metrics_agent']['enable']

Usage
-----

Include 'boxcutter_digitalocean::default' to configure all the agents for
a DigitalOcean instance.

### Droplet Agent

The DigitalOcean droplet agent is used to configure console access in the
DigitalOcean web GUI. Without this agent installed, the droplet console button
won't work.

You can use the `node['boxcutter_digitalocean']['droplet_agent']['enable']`
attribute to enable/disable the droplet agent. The default is `true` which
enables the agent.

### Metrics Agent

The DigitalOcean metric agent is used to send detailed telemetry to the
DigitalOcean backend. Without this agent installed, no metrics will be
displayed in the DigitalOcean web GUI.

You can use the `node['boxcutter_digitalocean']['metrics_agent']['enable']`
attribute to enable/disable the droplet agent. The default is `true` which
enables the agent.

