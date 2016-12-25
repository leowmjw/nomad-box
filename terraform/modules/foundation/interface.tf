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

variable "foundation_servers" {
  description = ""
}

variable "foundation_storage_uri" {
  description = ""
}

output "pubip" {
  value = [
    "${azurerm_public_ip.foundation_pubip.ip_address}"]
}

output "vnet" {
  value = "${azurerm_virtual_network.foundation_vnet.name}"
}