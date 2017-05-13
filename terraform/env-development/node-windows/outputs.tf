
output "private_ip_windows" {
  value = "${azurerm_network_interface.windows_netif.private_ip_address}"
}

output "internal_fdqn_windows" {
  value = "${azurerm_network_interface.windows_netif.internal_fqdn}"
}
