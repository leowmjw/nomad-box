# Foundation servers act as:
# Bastion host
# If NOT Dev mode; then spin up another 2nodes for rest of cluster ..
# Able to tweak the image type/size ..

variable "resource_group" {
  description = ""
}

variable "organization" {
  description = ""
}

variable "project" {
  description = ""
}

variable "environment" {
  description = ""
}

variable "region" {
  description = ""
}

variable "cidr_block" {
  description = ""
}

variable "num_servers" {
  description = ""
}

variable "instance_type" {
  description = "Foundation Nodes; suggest start with Standard_A1 or A0 since will run 3"
}

variable "storage_uri" {
  description = ""
}

variable "pub_key" {
  description = "Full path to the SSH Public Key to be copied over into the Azure instance"
}

output "pubip" {
  value = [
    "${azurerm_public_ip.foundation_pubip.ip_address}"]
}

output "vnet" {
  value = "${azurerm_virtual_network.foundation_vnet.name}"
}