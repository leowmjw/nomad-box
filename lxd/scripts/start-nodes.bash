#!/bin/bash
#

# Start up the services; should be ported to Systemd instead ..

# Start up eh foundational Consul
# laptop-consul.local:1111

cd /opt/nomad && ./nomad agent -server -bootstrap-expect=3 -data-dir=/tmp/nomad -config=./config.json &

# Start up Nomad UI in one of the nodes ..
# laptop-nomadui.local:1111

