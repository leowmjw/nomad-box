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

variable "foundation_servers" {
  description = ""
  default = 1
}

variable "director_distribution" {
  description = ""
  type = "map"
}

variable "worker_distribution" {
  description = ""
  type = "map"
  default = {
    count = 1
    instance_type = "Standard_A2"
  }
}

provider "azurerm" {
  subscription_id = "${var.azure_subscription_id}"
  client_id = "${var.azure_client_id}"
  client_secret = "${var.azure_client_secret}"
  tenant_id = "${var.azure_tenant_id}"
}

# Shared Resources Defined ...
resource "azurerm_resource_group" "foundation" {
  name = "${var.organization}-${var.project}-${var.environment}-foundation"
  location = "${var.region}"
}

resource "azurerm_storage_account" "foundation" {
  name = "${var.organization}${var.project}${var.environment}foundationsa"
  resource_group_name = "${azurerm_resource_group.foundation.name}"
  location = "${var.region}"
  #TODO:
  account_type = "Standard_LRS"
}

resource "azurerm_storage_container" "foundation" {
  name = "${var.organization}-${var.project}-${var.environment}-foundation-container"
  resource_group_name = "${azurerm_resource_group.foundation.name}"
  storage_account_name = "${azurerm_storage_account.foundation.name}"

  #TODO:
  container_access_type = "private"
}

module "foundation" {
  source = "../modules/foundation"
  resource_group = "${azurerm_resource_group.foundation.name}"

  organization = "${var.organization}"
  project = "${var.project}"
  environment = "${var.environment}"
  region = "${var.region}"

  cidr_block = "${var.cidr_block}"

  foundation_servers = "${var.foundation_servers}"

  foundation_storage_uri = "${azurerm_storage_account.foundation.primary_blob_endpoint}${azurerm_storage_container.foundation.name}"
}

module "director" {
  source = "../modules/director"

  resource_group = "${azurerm_resource_group.foundation.name}"

  organization = "${var.organization}"
  project = "${var.project}"
  environment = "${var.environment}"
  region = "${var.region}"

  cidr_block = "${var.cidr_block}"
  virtual_network = "${module.foundation.vnet}"

  num_servers = "${var.director_distribution["dev_count"]}"
  storage_uri = "${azurerm_storage_account.foundation.primary_blob_endpoint}${azurerm_storage_container.foundation.name}"
}

module "worker" {
  source = "../modules/worker"

  resource_group = "${azurerm_resource_group.foundation.name}"

  organization = "${var.organization}"
  project = "${var.project}"
  environment = "${var.environment}"
  region = "${var.region}"

  cidr_block = "${var.cidr_block}"
  virtual_network = "${module.foundation.vnet}"

  num_servers = "${var.worker_distribution["count"]}"
  instance_type = "${var.worker_distribution["instance_type"]}"
  storage_uri = "${azurerm_storage_account.foundation.primary_blob_endpoint}${azurerm_storage_container.foundation.name}"
}