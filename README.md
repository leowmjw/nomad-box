# Introduction to Nomad Box

An opinionated multi-provider multi-region Service Platform to easily and automatically handle development, packaging, testing, deployment and operations of Docker/GoLang/Java and legacy workloads.  Should provide frictionless tools to ease in all stages of the application lifecycle.

**Objective:** Example platform designed to leverage the complete Hashicorp Suite of Products (and determine the gaps).  Also as a learning exercise to compare/contrast against equivalent Kubernetes/Helm and Docker Swarm setup.

**Architecture**: [Introduction to Nomad Box on Azure](https://goo.gl/ReU12f)

**Planned Technologies:** Terraform, Consul, Nomad, Vault, Linkerd, Jaeger, Traefik, Hashi-UI, Vault-UI, Prometheus, BedrockDB, LXD, ZFS, Drone.io, Powershell.

**NOTE:** Only suitable in dev environments at the moment until I learn more Terraform, Consul, Nomad, Vault :P

## Getting Started

Generate credentials using the Azure CLI. If you're not logged in, execute `az login` first. See the [docs][login] for more info.

### Setup the first time:
```
leow$ make setup
Downloading Consul 0.8.1
cd bin && touch consul && rm consul* && \
	    curl -O "https://releases.hashicorp.com/consul/0.8.1/consul_0.8.1_darwin_amd64.zip" && \
	    unzip consul_0.8.1_darwin_amd64.zip
...
Setup the proper modules ..
cd ./terraform/env-development && time ../../bin/terraform get -update
Get: file:///Users/leow/Desktop/PROJECTS/DEVOPS/nomad-box/terraform/modules/foundation (update)
Get: file:///Users/leow/Desktop/PROJECTS/DEVOPS/nomad-box/terraform/modules/director (update)
Get: file:///Users/leow/Desktop/PROJECTS/DEVOPS/nomad-box/terraform/modules/worker (update)
Get: file:///Users/leow/Desktop/PROJECTS/DEVOPS/nomad-box/terraform/modules/experiment (update)

```

**Optional:** Setup different environment (defaults to env-development); if needed:
```
# leow$ export NOMAD_BOX_ENV=env-staging
```

**Config:** Copy the example terraform.tfvars.example  file (it is inside the environment folder [env-development](./terraform/env-development)) into terraform.tfvars. All statefile generated will be in the chosen environment


Credentials can be setup in Environment variable or inside the terraform.tfvars file
```
$ export ARM_SUBSCRIPTION_ID=abc-123-456
$ export ARM_CLIENT_ID=generated-app-id
$ export ARM_CLIENT_SECRET=generated-pass
$ export ARM_TENANT_ID=generated-tenant
```

### Plan (after adjusting number of each type nodes in terraform.tfvars):
```
leow$ make plan
Planning ..
cd ./terraform/env-development && time ../../bin/terraform plan
...
azurerm_virtual_machine.foundation_node.2: Refreshing state... (ID: /subscriptions/3fdd09c8-f36c-417f-9d13-...hines/acme-nomad-dev-foundation-node-3)
No changes. Infrastructure is up-to-date.

```

### Apply:
```
leow$ make apply
data.terraform_remote_state.nomadbox: Refreshing state...
azurerm_storage_blob.windows_cloudinit: Refreshing state... (ID: acme-nomad-dev-NomadBoxCloudInit.ps1)
...
azurerm_network_interface.windows_netif: Still destroying... (ID: /subscriptions/3fdd09c8-f36c-417f-9d13-...erfaces/acme-nomad-dev-windows-netif-1, 20s elapsed)
azurerm_network_interface.windows_netif: Destruction complete

Apply complete! Resources: 0 added, 0 changed, 3 destroyed.
```

### Refresh:
```
leow$ make refresh
echo "Refreshing .."
Refreshing ..
cd ./terraform/env-development && time ../../bin/terraform refresh
azurerm_resource_group.director: Refreshing state... (ID: /subscriptions/3fdd09c8-f36c-
...
Outputs:

bastion_pubip = [ a.b.c.d ]
director_internal_ips = []
director_public_fqdn = []
director_public_ips = []
...
virtual_network = acme-nomad-dev-foundation-vnet
worker_internal_ips = [
    10.0.101.4
]
worker_resource_group_name = acme-nomad-dev-worker
```

### Tunnel to Cluster:
```
leow$ make tunnel-up
Tunnel Up ..
sh -c  "sshuttle -r testadmin@a.b.c.d 10.0.0.0/16"
client: Connected.
```

### Running Workloads (vis Nomad)
Example Nomad Jobs: see [Example Jobs](./laptop/nomad-azure/jobs)

### Operations (-TODO-)
- Monitoring (Prometheus/Circonus)
- Tracing (Jaeger)
- Routing Functions: Canary, Blue/Green (Linkerd)
- Dashboard (Hashi-UI, Vault-UI)
- Autoscaling (Powershell Workflow w/ Control Theory)
- Load Balance (front Azure Traffic Manager/ AWS LB)
- Cluster Federation across providers

### Security (-TODO-)
- Security Group + ACL
- Encryption between Nodes
- Leverage Vault fully

### Destroy once cluster not needed:
```
leow$ make destroy
Removing infra ..
cd ./terraform/env-development && time ../../bin/terraform destroy
Do you really want to destroy?
  Terraform will delete all your managed infrastructure.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

azurerm_resource_group.foundation: Refreshing state... (ID: /subscriptions/3fdd09c8-f36c-417f-9d13-...sourceGroups/acme-nomad-dev-foundation)```
...
data.terraform_remote_state.nomadbox: Destruction complete

Destroy complete! Resources: 4 destroyed.
```

### Public Access
```
- Bastion Node: bastion_pubip
- Director Node (Traefik): director_public_ips
```

### Internal Access (via tunnel)
```
- Foundation Nodes: 10.0.1.4, 10.0.2.4, 10.0.3.4 (until Consul has support for retry-join-azure)
- Director Nodes: director_internal_ips
- Worker Nodes: worker_internal_ips
- Experimental Nodes: experiment_internal_ips
```

## Assumptions
- Internal Cluster Network CIDR 10.0.0.0/16
- sshuttle is installed 

## Inspiration

- cluster - https://github.com/mafonso/nomad-cluster
- konterraform - https://github.com/AppGyver/konterraform
- Turbo (great examples of multi-region clusters) https://github.com/jonmorehouse/turbo
- CoreOS Tectonic: https://github.com/coreos/tectonic-installer


[login]: https://docs.microsoft.com/en-us/cli/azure/get-started-with-azure-cli

