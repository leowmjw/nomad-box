provider "azurerm" {
  subscription_id = "${var.azure_subscription_id}"
  client_id = "${var.azure_client_id}"
  client_secret = "${var.azure_client_secret}"
  tenant_id = "${var.azure_tenant_id}"
}

# Separate Resource Group so it is easier to see costing
resource "azurerm_resource_group" "foundation" {
  name = "${var.organization}-${var.project}-${var.environment}-foundation"
  location = "${var.region}"
}

resource "azurerm_resource_group" "director" {
  name = "${var.organization}-${var.project}-${var.environment}-director"
  location = "${var.region}"
}

resource "azurerm_resource_group" "worker" {
  name = "${var.organization}-${var.project}-${var.environment}-worker"
  location = "${var.region}"
}

# Shared storage for all 3 type of nodes
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

# Foundation Nodes Defined ..
module "foundation" {
  source = "../modules/foundation"
  resource_group = "${azurerm_resource_group.foundation.name}"

  organization = "${var.organization}"
  project = "${var.project}"
  environment = "${var.environment}"
  region = "${var.region}"

  cidr_block = "${var.cidr_block}"

  num_servers = "${var.foundation_distribution["count"]}"
  instance_type = "${var.foundation_distribution["instance_type"]}"

  storage_uri = "${azurerm_storage_account.foundation.primary_blob_endpoint}${azurerm_storage_container.foundation.name}"

  pub_key = "${var.pub_key}"
}

# Director Nodes Defined ..
module "director" {
  source = "../modules/director"

  resource_group = "${azurerm_resource_group.director.name}"

  organization = "${var.organization}"
  project = "${var.project}"
  environment = "${var.environment}"
  region = "${var.region}"

  cidr_block = "${var.cidr_block}"
  virtual_network = "${module.foundation.vnet}"

  num_servers = "${var.director_distribution["count"]}"
  instance_type = "${var.director_distribution["instance_type"]}"

  storage_uri = "${azurerm_storage_account.foundation.primary_blob_endpoint}${azurerm_storage_container.foundation.name}"

  pub_key = "${var.pub_key}"
}

# Worker Nodes Defined ..
module "worker" {
  source = "../modules/worker"

  resource_group = "${azurerm_resource_group.worker.name}"

  organization = "${var.organization}"
  project = "${var.project}"
  environment = "${var.environment}"
  region = "${var.region}"

  cidr_block = "${var.cidr_block}"
  virtual_network = "${module.foundation.vnet}"

  num_servers = "${var.worker_distribution["count"]}"
  instance_type = "${var.worker_distribution["instance_type"]}"

  storage_uri = "${azurerm_storage_account.foundation.primary_blob_endpoint}${azurerm_storage_container.foundation.name}"

  pub_key = "${var.pub_key}"
}