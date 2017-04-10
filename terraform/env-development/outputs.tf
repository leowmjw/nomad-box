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
