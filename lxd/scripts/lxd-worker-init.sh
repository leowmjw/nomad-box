#!/bin/bash
#
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# This should be filled in by TF template using the Makefile ENV
NOMAD_BOX_VERSION_CONSUL=0.8.4
NOMAD_BOX_VERSION_NOMAD=0.5.6

# Setup the needed repos for BedrockDB + others ..
# START BedrockDB
# Add the Bedrock repo to apt sources for your distro:
# wget -O /etc/apt/sources.list.d/bedrock.list https://apt.bedrockdb.com/ubuntu/dists/$(lsb_release -cs)/bedrock.list
# wget -O - https://apt.bedrockdb.com/bedrock.gpg | sudo apt-key add -
# END BerdockDB

# Add the Microsoft needed info
# curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
# curl https://packages.microsoft.com/config/ubuntu/16.04/mssql-server.list | sudo tee /etc/apt/sources.list.d/mssql-server.list
# END MSSQL 2017 for Linux

# Get the basic packages
# export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get upgrade -y && \
#    apt-get install -y unzip dnsmasq sysstat docker.io bedrock jq mssql-server

# Get the basic packages
export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get upgrade -y && \
    apt-get install -y unzip jq
# # Leave out Bedrock for now; optional SW should be parameterized; or as part of Packer/templatized
# export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get upgrade -y && \
#     apt-get install -y unzip dnsmasq sysstat docker.io docker-compose jq

# Setup resolved in systemd to use Consul if possible ..
cat > /etc/systemd/resolved.conf  <<EOF
[Resolve]
  DNS=10.1.1.1 10.1.2.1 10.1.3.1
  FallbackDNS=1.1.1.1 8.8.8.8
  Domains=~consul
EOF

systemctl restart systemd-resolved

# Consul operates in /opt
# ========================
mkdir -p /opt/consul
cd /opt/consul

# Get the binaries
wget "https://releases.hashicorp.com/consul/${NOMAD_BOX_VERSION_CONSUL}/consul_${NOMAD_BOX_VERSION_CONSUL}_linux_amd64.zip"
unzip consul_${NOMAD_BOX_VERSION_CONSUL}_linux_amd64.zip

# Setup needed folders and start service; to be replaced in systemd
mkdir ./consul.d

# Extract the IP address from the determined interface
CONSUL_CLIENT_INTERFACE="eth0"
CONSUL_CLIENT_ADDRESS=$(ip -o -4 addr list $CONSUL_CLIENT_INTERFACE | head -n1 | awk '{print $4}' | cut -d/ -f1)
# Use that address to setup the HTTP endpoint so that it is reachable from within Docker container
cat > ./consul.d/config.json <<EOF
{
    "addresses": {
        "http": "${CONSUL_CLIENT_ADDRESS}"
    }
}
EOF

# Extract the IP address from the determined interface
CONSUL_BIND_INTERFACE="eth0"
CONSUL_BIND_ADDRESS=$(ip -o -4 addr list $CONSUL_BIND_INTERFACE | head -n1 | awk '{print $4}' | cut -d/ -f1)

# Start up the Consul agent
/opt/consul/consul agent -data-dir=/tmp/consul -config-dir=./consul.d \
  -retry-join=10.1.1.4 -retry-join=10.1.2.4 -retry-join=10.1.3.4 \
  -bind=${CONSUL_BIND_ADDRESS} -client=${CONSUL_BIND_ADDRESS} -disable-host-node-id &

# Setup dnsmsq
# From: https://github.com/darron/kvexpress-demo/blob/c0bd1733f0ad78979a34242d5cfe9961b0c3cabd/ami-build/provision.sh#L42-L56
# From: https://www.consul.io/docs/guides/forwarding.html
# =======================================================
# create the needed folders
# mkdir -p /var/log/dnsmasq/ && chmod 755 /var/log/dnsmasq

# # Setup config file for dnsmasq
# cat > /etc/dnsmasq.d/10-consul <<EOF
# # Enable forward lookup of the 'consul' domain:
# server=/consul/127.0.0.1#8600

# # Uncomment and modify as appropriate to enable reverse DNS lookups for
# # common netblocks found in RFC 1918, 5735, and 6598:
# rev-server=10.0.0.0/8,127.0.0.1#8600

# # Accept DNS queries only from hosts whose address is on a local subnet.
# local-service

# EOF

# cat > /etc/default/dnsmasq <<EOF
# DNSMASQ_OPTS="--log-facility=/var/log/dnsmasq/dnsmasq --local-ttl=10"
# ENABLED=1
# CONFIG_DIR=/etc/dnsmasq.d,.dpkg-dist,.dpkg-old,.dpkg-new
# EOF

# # Start the service ...
# service dnsmasq restart


# Setup Nomad (must run as root) ..
# ====================================
# Nomad operates in /opt
mkdir -p /opt/nomad
cd /opt/nomad

# Get the binaries
wget "https://releases.hashicorp.com/nomad/${NOMAD_BOX_VERSION_NOMAD}/nomad_${NOMAD_BOX_VERSION_NOMAD}_linux_amd64.zip"
unzip nomad_${NOMAD_BOX_VERSION_NOMAD}_linux_amd64.zip

# Setup needed folders and start service; to be replaced in systemd
mkdir ./jobs

# Setup the pointing of consul to the agent running locally
cat > ./config.json <<EOF
{
    "consul": {
        "address": "${CONSUL_CLIENT_ADDRESS}:8500"
    },
    "addresses": {
        "http": "${CONSUL_CLIENT_ADDRESS}"
    }
}
EOF

# Run both as client; taking consul config from above ...
# TODO: Pass in tags into meta perhaps ..; for now workers tagged as "primary", can be used to constrain
./nomad agent -node-class=primary -client -servers=10.1.1.4,10.1.2.4,10.1.3.4 -data-dir=/tmp/nomad -config=./config.json &

# Setup installation of th latest MSSQL 2017 for Linux .. neat!
# SA_PASSWORD="TestAdmin123456" /opt/mssql/bin/mssql-conf setup accept-eula

