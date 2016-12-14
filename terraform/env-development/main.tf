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

}
variable "region" {
  description = ""

}
variable "cidr_block" {
  description = ""

}
variable "key_name" {
  description = ""

}
variable "domain_name_servers" {
  description = ""
  type = "list"
}

provider "azurerm" {
  subscription_id = "${var.azure_subscription_id}"
  client_id = "${var.azure_client_id}"
  client_secret = "${var.azure_client_secret}"
  tenant_id = "${var.azure_tenant_id}"
}

resource "azurerm_resource_group" "foundation" {
  name = "${var.organization}-${var.project}-${var.environment}-foundation"
  location = "${var.region}"
}

resource "azurerm_storage_account" "foundation" {
  name = "${var.organization}${var.project}${var.environment}foundation"
  resource_group_name = "${azurerm_resource_group.foundation.name}"
  location = "${var.region}"
  #TODO:
  account_type = "Standard_LRS"
}

resource "azurerm_storage_container" "foundation" {
  name = "${var.organization}-${var.project}-${var.environment}-foundation"
  resource_group_name = "${azurerm_resource_group.foundation.name}"
  storage_account_name = "${azurerm_storage_account.foundation.name}"

  #TODO:
  container_access_type = "private"
}