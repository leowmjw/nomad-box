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
