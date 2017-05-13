# Setup Nomad Box Cluster on Laptop (via VirtualBox + LXD)

## Basic Setup for Azure Credentials for use by Terraform (Quickstart)

### Create Azure Credentials
```
- make deps (This gets the Azure CLI tool on OSX if not installed yet)
- make setup (This gets the needed binaries like Terraform, Nomad)
- az login (Take note of Subscription ID)
- az ad sp create-for-rbac -n "http://LaravelDemo" --role contributor --scopes /subscriptions/<Subscription ID>/
- Take note of the output from command above:
    * client_id => name or appId (can be used interchangeably)
    * client_secret => password
    * tenant_id => tenant

```

### Test Azure Credentials
- Copy below into a main.tf; and execute terraform plan and it should NOT show any errors
```
# Configure the Microsoft Azure Provider
provider "azurerm" {  
  subscription_id = "..."
  client_id       = "..."
  client_secret   = "..."
  tenant_id       = "..."
}

# Create a resource group
resource "azurerm_resource_group" "production" {  
  name     = "production"
  location = "East US"
}
```

## Environments

- Development (Individual CI/CD)
- Staging (Team CI/CD)
- Production (End-to-End Test, Security Test, Load Test)

## Network Details

- Foundation Subnet/Nodes: [ 10.0.1.1/24.. ]
- Director Subnet/Nodes: [ 10.0.101.1/24.. ]
- Worker Subnet/Nodes: [ 10.0.151.1/24.. ]