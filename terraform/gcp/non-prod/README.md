# Non Production Configuration
GCP Setup for use by devs and testers and bots

## Rationale: 
Separating non-prod with prod will ensure there is no "accidental" mistakes.  Should be suitable up till CI/CD

## Objective: 
- Fully utilize the env to have multiple dev environments and multiple staging environments too! Picture scenario with multiple devs and a CI/CD running
- New Makefiles inside this scope to use top level S/W versions to be propagated down into the templates for cloud-init
- Have rolling upgrade of Consul + Nomad servers
- Have Security in Group; with limitation for inner nodes only via Bastion host; bastion host placed in experimental node; and limited to terraform IP connecting in?
- Have the Autoscaling in place for Worker class of nodes
- Add Traffic Manager in front of the Traefik nodes
- Have more attributes to mark different classes of nodes (GPU, IO, CPU etc.)
- Fully utilize S3 + DynamoDB to manage GCP state(!)
- Cloud-init fully templatized (with subnet params) and using systemd to ensure restart; possibly using converge or maybe via template composition will be better
- Any other folder will be on per project basis and can rely on remote state from either the common infra with org-wide capacity or from the shared nomad cluster
- Example project will be setup for a training session for Terraform as per Seth Vargo's example; all with the necessary minimal IAM credentials
- Stretch goal to evaluate how terragrunt can help out in this situation
- Another stretch is to have brocolli in place so that non-ops can deploy their own workload
- Final stretch to add Vault nodes, vault-ui + the semi-auto unlock with Yubikey + multinode
 