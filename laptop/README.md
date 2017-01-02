# Simple Laptop Proxy Setup to Nomad Box Cluster

## Objective

Make it as easy as possible

## Steps (LXD)

0. Ensure the pre-requisite software is installed: npm / yarn, sshuttle, Virtualbox, nomad
1. <Go to Vagrantfile folder>: vagrant up
2. Go to the folder nomad-lxd:
3. Start the cluster: nomad-box up <simple|director|full>
4. Setup Tunnel: nomad-box tunnel up
5. Get nomad agent running: nomad-box agent up
6. List some apps: nomad-box exec list
7. Try some apps: nomad-box exec whoami.nomad
8. Setup the proxy: nomad-box proxy up
9. Go to the Management pages: consul.local:4444, nomad.local:4444, treafik.local:4444
10. Go test out the apps: quote.local:4444, nodered.local:4444, whoami.local:4444
...
Done
1. Shut down proxy: nomad-box proxy down
2. Shut down tunnel: nomad-box tunnel down
3. <Go to Vagrantfile folder>: vagrant down

## Steps (Azure)

## Directory Structure

- jobs: Put the Nomad jobs here; possibly need to be auto-generated based on a workflow
- proxy: Put the scripts to setup the local Proxy (powered by Caddy) and local DNS (via mDNS)