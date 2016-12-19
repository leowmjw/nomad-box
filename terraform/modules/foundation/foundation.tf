# Main Virtual Network ...
resource "azurerm_virtual_network" "foundation_vnet" {
  name = "${var.organization}-${var.project}-${var.environment}-foundation-vnet"
  location = "${var.region}"
  resource_group_name = "${var.resource_group}"

  address_space = [
    "${var.cidr_block}"]

}

# Subnets as per defined
resource "azurerm_subnet" "foundation_subnet" {
  count = "${var.foundation_servers}"

  name = "${var.organization}-${var.project}-${var.environment}-foundation-subnet-${count.index + 1}"
  resource_group_name = "${var.resource_group}"

  virtual_network_name = "${azurerm_virtual_network.foundation_vnet.name}"
  # address_prefix = "${element(var.foundation_subnets, count.index)}"
  address_prefix = "${cidrsubnet(var.cidr_block, 8, count.index + 1)}"

  # HOWTO security; here??
  # network_security_group_id = ""
  # WAN routing next time?
  # route_table_id = ""
}

# Public IP for main Bastion?
resource "azurerm_public_ip" "foundation_pubip" {
  count = 1

  name = "${var.organization}-${var.project}-${var.environment}-foundation-pubip"
  resource_group_name = "${var.resource_group}"
  location = "${var.region}"

  domain_name_label = "${var.organization}-${var.project}-${var.environment}-bastion"
  public_ip_address_allocation = "dynamic"

}

# Network interfaces for each defined subnets
resource "azurerm_network_interface" "foundation_netif" {
  count = "${var.foundation_servers}"

  name = "${var.organization}-${var.project}-${var.environment}-foundation-netif-${count.index + 1}"
  resource_group_name = "${var.resource_group}"
  location = "${var.region}"

  ip_configuration {
    name = "ipconf-${count.index + 1}"
    subnet_id = "${element(azurerm_subnet.foundation_subnet.*.id, count.index)}"
    # Public IP only for the first Foundation host (e.g Bastion Host)
    public_ip_address_id = "${count.index == 0 ? azurerm_public_ip.foundation_pubip.id : ""}"
    # public_ip_address_id = "${count.index == 0 ? azurerm_public_ip.foundation_pubip.id : ''}"
    private_ip_address_allocation = "static"
    private_ip_address = "${cidrhost(cidrsubnet(var.cidr_block, 8, count.index + 1), 1)}"
  }

  # Primary node more liberal; the rest lock down?
  # network_security_group_id = ""
  internal_dns_name_label = "${var.organization}-${var.project}-${var.environment}-foundation-node-subnet${count.index + 1}"
  enable_ip_forwarding = true

  tags {
    type = "Foundation"
  }

}
