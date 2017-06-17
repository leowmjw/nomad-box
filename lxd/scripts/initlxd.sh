#!/bin/bash
#
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

echo "Initializing LXD ..."

# LXD needs the bleeding edge; thus add as per below to get at LXD + ZFS
export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y software-properties-common python-software-properties && \
    add-apt-repository -y ppa:ubuntu-lxc/lxd-git-master && \
    apt-get update && apt-get install -y lxd zfsutils-linux

# Can consider to remove M$ extra management cruft?
# sudo apt remove -y walinuxagent && sudo apt autoremove -y

echo "Setting up ZFS ...."
if [[ "x" == $AZURE_MODE ]]
then
    # Start Azure-specific
    # Create the block; production should likely link to Data Disk
    # Is the ephemeral block good enough? This gives 100GB sparse; but underlying device is only 30GB; beware!!
    # Setup ZPool with name and with sparse size 100GB?
    # Note, no mirror nor any redundancy; for real production do ensure at least mirroring or raidz!!
    # Use the temporary device as a ZFS cache
    # Not a good idea as it is used for swap? Doing below will sacrifice the swap; or will it
    # Double checked; swap not being enabled! IO here should be good; or turn it into swap :P
    # Idea: Choose disk 30GB; temp will be ~50% = 14GB
    # Mirror: 14GB along with 14GB that is file backed
    # Cache: 5GB file backed ..
    echo "Azure mode"
    dd if=/dev/zero of=/var/lib/lxd/zfs-azure.img bs=1k count=1 seek=100M && \
        zpool create my-zfs-pool /var/lib/lxd/zfs-azure.img && \
        umount /mnt && zpool add -f my-zfs-pool cache /dev/sdb
    ## End Azure-specific
else
    dd if=/dev/zero of=/var/lib/lxd/zfs.img bs=1k count=1 seek=100M && \
        zpool create my-zfs-pool /var/lib/lxd/zfs.img
fi

echo "Setting up LXD .."
# Init LXD as per in docs ...
cat <<EOF | lxd init --verbose --preseed
# Daemon settings
config:
  core.https_address: 0.0.0.0:9999
  core.trust_password: passw0rd
  images.auto_update_interval: 36

# Storage pools
storage_pools:
- name: data
  driver: zfs
  config:
    source: my-zfs-pool/my-zfs-dataset

# Network devices
networks:
- name: lxd-my-bridge
  type: bridge
  config:
    ipv4.address: auto
    ipv6.address: none

# Profiles
profiles:
- name: default
  devices:
    root:
      path: /
      pool: data
      type: disk
- name: test-profile
  description: "Test profile"
  config:
    limits.memory: 2GB
  devices:
    test0:
      name: test0
      nictype: bridged
      parent: lxd-my-bridge
      type: nic
EOF

# Run some test actions to create nodes
# How to copy the i,age and get it going .. with alias for zesty ..
# Pull 16.04 and latest; have options to select ..
# Use the Ubuntu nodes so can run cloud-init??
lxc profile create foundation
# Need to provide the cloud-init.sh scripts ..
lxc profile set foundation user.user-data - < /tmp/script/init.sh
# Exec in and confirm it is running
lxc init zesty -p default -p foundation f1 && \
    lxc network attach fsubnet1 f1 eth0 && \
    lxc config device set f1 eth0 ipv4.address 10.1.1.4

lxc init zesty -p default -p foundation f2 && \
    lxc network attach fsubnet2 f2 eth0 && \
	lxc config device set f2 eth0 ipv4.address 10.1.2.4

lxc init zesty -p default -p foundation f3 && \
    lxc network attach fsubnet3 f3 eth0 && \
	lxc config device set f3 eth0 ipv4.address 10.1.3.4

lxc start f1 && lxc start f2 && lxc start f3

# Templates build from common