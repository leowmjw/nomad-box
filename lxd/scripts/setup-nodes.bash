#!/bin/bash
#

# Assumes LXC + LXD is installed

# Clean up instances
lxc delete --force f1
lxc delete --force f2
lxc delete --force f3

# Clean up network interfaces
lxc network delete fsubnet1
lxc network delete fsubnet2
lxc network delete fsubnet3

# Setup base network ..
lxc network create fsubnet1 ipv6.address=none ipv4.address=10.1.1.1/24 ipv4.nat=true
lxc network create fsubnet2 ipv6.address=none ipv4.address=10.1.2.1/24 ipv4.nat=true
lxc network create fsubnet3 ipv6.address=none ipv4.address=10.1.3.1/24 ipv4.nat=true

# Setup instance nodes
lxc init ubuntu f1
lxc init ubuntu f2
lxc init ubuntu f3

# Init first; setup static ip address
lxc network attach fsubnet1 f1 eth0 && \
	lxc config device set f1 eth0 ipv4.address 10.1.1.4

lxc network attach fsubnet2 f2 eth0 && \
	lxc config device set f2 eth0 ipv4.address 10.1.2.4

lxc network attach fsubnet3 f3 eth0 && \
	lxc config device set f3 eth0 ipv4.address 10.1.3.4

# Attach shared config
lxc config device add f1 sharedtmp disk path=/tmp/shared source=/vagrant
lxc config device add f2 sharedtmp disk path=/tmp/shared source=/vagrant
lxc config device add f3 sharedtmp disk path=/tmp/shared source=/vagrant

# Start all node serially
lxc start f1 && lxc start f2 && lxc start f3

# Wait a short while ...
sleep 5

# List out details
lxc list

# Exec in parallel!!
lxc exec f1 -- /tmp/shared/mystart.bash 
lxc exec f2 -- /tmp/shared/mystart.bash 
lxc exec f3 -- /tmp/shared/mystart.bash 


