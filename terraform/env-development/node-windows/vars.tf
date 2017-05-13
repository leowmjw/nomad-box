# Inout variables
variable "azure_subscription_id" {
  description = ""
}

variable "azure_client_id" {
  description = ""
}

variable "azure_client_secret" {
  description = ""
}

variable "azure_tenant_id" {
  description = ""
}

variable "organization" {
  description = ""
  default = "acme"
}

variable "project" {
  description = ""
  default = "nomad"
}

variable "environment" {
  description = ""
  default = "dev"
}

variable "cidr_block" {
  description = ""
  default = "10.0.0.0/16"
}

// TODO: Put here options for Nano once the standard working is done and
// can control from Linux via Powershell ...?
variable "windows_distribution" {
  description = ""
  type = "map"
  default = {
    count = 1
    instance_type = "Standard_D1_v2"
    offer = "WindowsServer"
    sku = "2016-Datacenter-with-Containers"
  }
}

