#!/bin/bash
#

# Assumes LXC + LXD is installed

# Clean up instances
lxc delete --force d1
lxc delete --force d2
lxc delete --force w1
lxc delete --force w2

# Clean up network interfaces
lxc network delete dsubnet1
lxc network delete dsubnet2
lxc network delete wsubnet1
lxc network delete wsubnet2

# Setup base network ..
lxc network create dsubnet1 ipv6.address=none ipv4.address=10.1.51.1/24 ipv4.nat=true
lxc network create dsubnet2 ipv6.address=none ipv4.address=10.1.52.1/24 ipv4.nat=true
lxc network create wsubnet1 ipv6.address=none ipv4.address=10.1.101.1/24 ipv4.nat=true
lxc network create wsubnet2 ipv6.address=none ipv4.address=10.1.102.1/24 ipv4.nat=true

# Setup instance nodes
lxc init ubuntu d1
lxc init ubuntu d2
lxc init ubuntu w1
lxc init ubuntu w2

# Init first; setup static ip address; not necessary; leave it dynamic
lxc network attach dsubnet1 d1 eth0 
# lxc network attach fsubnet1 f1 eth0 && \
#	lxc config device set f1 eth0 ipv4.address 10.1.1.4

lxc network attach dsubnet2 d2 eth0 
# lxc network attach fsubnet2 f2 eth0 && \
#	lxc config device set f2 eth0 ipv4.address 10.1.2.4

lxc network attach wsubnet1 w1 eth0 
# lxc network attach fsubnet3 f3 eth0 && \
#	lxc config device set f3 eth0 ipv4.address 10.1.3.4

lxc network attach wsubnet2 w2 eth0 

# Attach shared config
lxc config device add d1 sharedtmp disk path=/tmp/shared source=/vagrant
lxc config device add d2 sharedtmp disk path=/tmp/shared source=/vagrant
lxc config device add w1 sharedtmp disk path=/tmp/shared source=/vagrant
lxc config device add w2 sharedtmp disk path=/tmp/shared source=/vagrant

# Start all node serially
lxc start d1 && lxc start d2 && lxc start w1 && lxc start w2

# Wait a short while ...
sleep 5

# List out details
lxc list

# Exec in parallel!!
lxc exec d1 -- /tmp/shared/director-start.bash 
lxc exec d2 -- /tmp/shared/director-start.bash 
lxc exec w1 -- /tmp/shared/worker-start.bash 
lxc exec w2 -- /tmp/shared/worker-start.bash 


