output "resource_group_name" {
  value = "${azurerm_resource_group.foundation.name}"
}

output "worker_resource_group_name" {
  value = "${azurerm_resource_group.worker.name}"
}

output "resource_group_location" {
  value = "${azurerm_resource_group.foundation.location}"
}

output "storage_account_name" {
  value = "${azurerm_storage_account.foundation.name}"
}

output "storage_container_name" {
  value = "${azurerm_storage_container.foundation.name}"
}

output "storage_uri" {
  value = "${azurerm_storage_account.foundation.primary_blob_endpoint}${azurerm_storage_container.foundation.name}"
}


output "virtual_network" {
  value = "${module.foundation.vnet}"
}

output "bastion_pubip" {
  value = "${module.foundation.pubip}"
}

output "director_internal_ips" {
  value = "${module.director.internal_ips}"
}

output "director_public_ips" {
  value = "${module.director.public_ips}"
}

output "director_public_fqdn" {
  value = "${module.director.public_fqdn}"
}

output "worker_internal_ips" {
  value = "${module.worker.internal_ips}"
}

output "experiment_public_ips" {
  value = "${module.experiment.public_ips}"
}

output "experiment_public_fqdn" {
  value = "${module.experiment.public_fqdn}"
}

output "experiment_internal_ips" {
  value = "${module.experiment.internal_ips}"
}
