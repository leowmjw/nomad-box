#!/bin/bash
#

# Assumes availability of Make? This script will be invoked from Makefile to cd to this directory

# Install / invoke npm / yarn? Better for it to be in the Makefile?

# Download specified Caddy version?

# Start Nomad Agent after copy config file
cp -a ../nomad-azure/config.json /tmp/.
# Start agent ..
../../bin/nomad agent -client -servers=10.0.1.4,10.0.2.4,10.0.3.4 -data-dir=/tmp/nomad -config=/tmp/config.json &

# Output the interpolated Caddyfile template with information from <where>?
cp -a ../templates/Caddyfile ~/NOMAD/CADDY/.

# Probably want to copy all the needed files to the execution folder as well
# Below show example of libs, script, binaries already prepared .. :P
# Files to copy are mycaddy.bash + bonjour.js; along with interpolation??
cp -a bonjour.js ~/NOMAD/CADDY/.
cp -a mycaddy.bash ~/NOMAD/CADDY/.
cd ~/NOMAD/CADDY/

# Invoke mycaddy to get things started ..
./mycaddy.bash

