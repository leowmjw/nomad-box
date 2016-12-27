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

}

variable "project" {
  description = ""

}
variable "environment" {
  description = ""
  default = "dev"
}

variable "region" {
  description = ""
  default = "South East Asia"
}

variable "cidr_block" {
  description = ""
  default = "10.0.0.0/16"
}

variable "key_name" {
  description = ""
}

variable "domain_name_servers" {
  description = ""
  type = "list"
}

variable "foundation_distribution" {
  description = ""
  type = "map"
  default = {
    count = 3
    instance_type = "Standard_A1"
  }
}

variable "director_distribution" {
  description = ""
  type = "map"
  default = {
    count = 1
    instance_type = "Standard_A1"
  }
}

variable "worker_distribution" {
  description = ""
  type = "map"
  default = {
    count = 0
    instance_type = "Standard_A2"
  }
}

variable "pub_key" {
  description = "Full path to the SSH Public Key to be copied over into the Azure instance"
}