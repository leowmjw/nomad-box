NOMAD_BOX_VERSION=v0.0.1
NOMAD_BOX_VERSION_TERRAFORM=0.8.8
NOMAD_BOX_VERSION_CONSUL=0.7.2
NOMAD_BOX_VERSION_NOMAD=0.5.2
NOMAD_BOX_VERSION_NOMAD_UI=v0.12.0
NOMAD_BOX_VERSION_TRAEFIK=v0.x.y
NOMAD_BOX_VERSION_CADDY=v0.z.a
NOMAD_BOX_VAGRANT=/Users/leow/OTTO/lxd-lab

default: info

setup:
	echo "Setting up .. Nomad Box!! in .. `pwd`"

	echo "Downloading Consul ${NOMAD_BOX_VERSION_CONSUL}"
	cd bin && touch consul && rm consul* && \
	    curl -O "https://releases.hashicorp.com/consul/${NOMAD_BOX_VERSION_CONSUL}/consul_${NOMAD_BOX_VERSION_CONSUL}_darwin_amd64.zip" && \
	    unzip consul_${NOMAD_BOX_VERSION_CONSUL}_darwin_amd64.zip

	echo "Downloading Nomad ${NOMAD_BOX_VERSION_NOMAD}"
	cd bin && touch nomad && rm nomad* && \
	    curl -O "https://releases.hashicorp.com/nomad/${NOMAD_BOX_VERSION_NOMAD}/nomad_${NOMAD_BOX_VERSION_NOMAD}_darwin_amd64.zip" && \
	    unzip nomad_${NOMAD_BOX_VERSION_NOMAD}_darwin_amd64.zip

	echo "Downloading Terraform ${NOMAD_BOX_VERSION_TERRAFORM}"
	cd bin && touch terraform && rm terraform* && \
	    curl -O "https://releases.hashicorp.com/terraform/${NOMAD_BOX_VERSION_TERRAFORM}/terraform_${NOMAD_BOX_VERSION_TERRAFORM}_darwin_amd64.zip" && \
	    unzip terraform_${NOMAD_BOX_VERSION_TERRAFORM}_darwin_amd64.zip

info:
	echo "Info ..."

plan:
	echo "Planning .."
	cd ./terraform/env-development && time ../../bin/terraform plan

apply:
	echo "Executing plan .."
	cd ./terraform/env-development && time ../../bin/terraform apply

refresh:
	echo "Refreshing .."
	cd ./terraform/env-development && time ../../bin/terraform refresh

destroy:
	echo "Removing infra .."
	cd ./terraform/env-development && time ../../bin/terraform destroy

local:
	./bin/consul -dev && ./bin/nomad -dev 

vagrant-up:
	echo "Vagrant Up .."

cluster-up:
	echo "Cluster Up.."

tunnel-up:
	echo "Tunnel Up .."
	touch ~/.ssh/known_hosts && rm ~/.ssh/known_hosts
	sh -c  "sshuttle -r testadmin@$(shell ./bin/terraform output -state=./terraform/env-development/terraform.tfstate bastion_pubip) 10.0.0.0/16"

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

