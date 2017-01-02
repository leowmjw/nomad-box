NOMAD_BOX_VERSION=v0.0.1
NOMAD_BOX_VERSION_CONSUL=v0.7.2
NOMAD_BOX_VERSION_NOMAD=v0.5.2
NOMAD_BOX_VERSION_NOMAD_UI=v0.12.0
NOMAD_BOX_VERSION_TRAEFIK=v0.x.y
NOMAD_BOX_VERSION_CADDY=v0.z.a
NOMAD_BOX_VAGRANT=/Users/leow/OTTO/lxd-lab

default: setup vagrant-up cluster-up tunnel-up proxy-up agent-up

setup:
	echo "Setting up .. Nomad Box!! in .. `pwd`"
	echo "Caddy version is ${NOMAD_VERSION_CADDY}"

vagrant-up:
	echo "Vagrant Up .."

cluster-up:
	echo "Cluster Up.."

tunnel-up:
	echo "Tunnel Up .."
	touch ~/.ssh/known_hosts && rm ~/.ssh/known_hosts
	sshuttle -r testadmin@$(~/TERRAFORM/terraform output -state=./terraform/env-development/terraform.tfstate bastion_pubip) 10.0.0.0/16

proxy-up:
	echo "Tunnel Up .."

agent-up:
	echo "Agent Up .."

agent-down:
	echo "Agent Down .."

proxy-down:
	echo "Tunnel Down .."

tunnel-down:
	echo "Tunnel Down .."

cluster-down:
	echo "Cluster Down.."

vagrant-down:
	echo "Vagrant Down .."

