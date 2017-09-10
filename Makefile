# Courtesy of: https://www.cmcrossroads.com/article/setting-makefile-variable-outside-makefile
NOMAD_BOX_VERSION?=v0.0.1
NOMAD_BOX_VERSION_TERRAFORM=0.9.11
NOMAD_BOX_VERSION_CONSUL=0.9.2
NOMAD_BOX_VERSION_NOMAD=0.6.2
NOMAD_BOX_VERSION_HASHI_UI=0.17.0
NOMAD_BOX_VERSION_TRAEFIK=1.3.7
NOMAD_BOX_VERSION_CADDY=v0.z.a
NOMAD_BOX_ENV?=env-development
NOMAD_BOX_NET?="10.0.0.0/16"
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

	echo "Downloading Hashi UI"
	cd bin && touch hashi-ui-darwin-amd64 && rm hashi-ui-darwin-amd64 && \
	    curl -L -O "https://github.com/jippi/hashi-ui/releases/download/v${NOMAD_BOX_VERSION_HASHI_UI}/hashi-ui-darwin-amd64" && \
	    chmod +x hashi-ui-darwin-amd64

	echo "Downloading Terraform ${NOMAD_BOX_VERSION_TERRAFORM}"
	cd bin && touch terraform && rm terraform* && \
	    curl -O "https://releases.hashicorp.com/terraform/${NOMAD_BOX_VERSION_TERRAFORM}/terraform_${NOMAD_BOX_VERSION_TERRAFORM}_darwin_amd64.zip" && \
	    unzip terraform_${NOMAD_BOX_VERSION_TERRAFORM}_darwin_amd64.zip

	echo "Setup the proper modules .."
	cd ./terraform/${NOMAD_BOX_ENV} && time ../../bin/terraform get -update

deps:
	brew install sshuttle
	curl -L https://aka.ms/InstallAzureCli | bash

info:
	echo "Nomad Box Version: ${NOMAD_BOX_VERSION}"

plan:
	echo "Planning .."
	cd ./terraform/${NOMAD_BOX_ENV} && time ../../bin/terraform plan

apply:
	echo "Executing plan .."
	cd ./terraform/${NOMAD_BOX_ENV} && time ../../bin/terraform apply

refresh:
	echo "Refreshing .."
	cd ./terraform/${NOMAD_BOX_ENV} && time ../../bin/terraform refresh

destroy:
	echo "Removing infra .."
	cd ./terraform/${NOMAD_BOX_ENV} && time ../../bin/terraform destroy

local:
	./bin/consul -dev && ./bin/nomad -dev 

vagrant-up:
	echo "Vagrant Up .."

cluster-up:
	echo "Cluster Up.."
	cd ./laptop/scripts && ./init.sh

cluster-down:
	echo "Cluster Down.."
	# To be moved to maybe a terminating script?
	kill `pgrep nomad` && kill `pgrep node` && sudo kill `pgrep caddy`

tunnel-up:
	echo "Tunnel Up .."
	touch ~/.ssh/known_hosts && rm ~/.ssh/known_hosts
	sh -c  "sshuttle -vH -r testadmin@$(shell ./bin/terraform output -state=./terraform/${NOMAD_BOX_ENV}/terraform.tfstate bastion_pubip) ${NOMAD_BOX_NET}"

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

vagrant-down:
	echo "Vagrant Down .."

