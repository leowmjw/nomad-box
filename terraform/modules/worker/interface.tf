#############################################################################
# Workers will act as the workhorse; isolated into private network; put storage too?
# Worker nodes should be in the private subnet (start 100..)
#############################################################################

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
  default = "Standard_F2"
}

variable "storage_uri" {
  description = ""
}

output "internal_ips" {
  value = [
    "${azurerm_network_interface.worker_netif.*.private_ip_address}"
  ]

}
