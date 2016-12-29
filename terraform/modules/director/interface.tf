#############################################################################
# Directors will act as the public facing node (put in isolated public subnet 50..)
# with Traefik/Fabio nodes load balancing to internal web services
# Difference is Worker nodes should be in the private subnet (start 100..)
#############################################################################

variable "node_type" {
  description = "Node Type; will use this to refactor for both Directors/Workers"
  default = "director"
}

variable "foundation_resource_group" {
  description = ""
}

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

variable "virtual_network" {
  description = "The VNet all Directors/Workers should be in; shared with the FOundationals"
}

variable "num_servers" {
  description = ""
}

variable "instance_type" {
  description = "Should be passed in from calling; based on env type?"
}

variable "storage_uri" {
  description = ""
}

variable "pub_key" {
  description = "Full path to the SSH Public Key to be copied over into the Azure instance"
}

output "internal_ips" {
  value = [
    "${azurerm_network_interface.director_netif.*.private_ip_address}"
  ]

}

output "public_ips" {
  value = [
    "${azurerm_public_ip.director_pubip.*.ip_address}"]
}

output "public_fqdn" {
  value = [
    "${azurerm_public_ip.director_pubip.*.fqdn}"]
}