# Main Virtual Network ...
resource "azurerm_virtual_network" "foundation_vnet" {
  name = "${var.organization}-${var.project}-${var.environment}-foundation-vnet"
  location = "${var.region}"
  resource_group_name = "${var.resource_group}"

  address_space = [
    "${var.cidr_block}"]

}

# Availability sets depending if it is clustered
resource "azurerm_availability_set" "foundation_aset" {
  # If single node; no need?
  count = 1
  name = "${var.organization}-${var.project}-${var.environment}-foundation-aset"
  location = "${var.region}"
  resource_group_name = "${var.resource_group}"
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

  # In order to prevent something like: https://github.com/hashicorp/terraform/issues/7153
  # Also will need to add dependency on security group once that is added here
  #     IFF it appears >= TF 0.8.x ..
  # depends_on = ["azurerm_virtual_network.foundation_vnet"]
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
    private_ip_address = "${cidrhost(cidrsubnet(var.cidr_block, 8, count.index + 1), 4)}"
  }

  # Primary node more liberal; the rest lock down?
  # network_security_group_id = ""
  internal_dns_name_label = "${var.organization}-${var.project}-${var.environment}-foundation-node-subnet${count.index + 1}"
  enable_ip_forwarding = true

  tags {
    type = "Foundation"
  }

}

# Next; setup the virtual_machines
resource "azurerm_virtual_machine" "foundation_node" {
  count = "${var.foundation_servers}"
  name = "${var.organization}-${var.project}-${var.environment}-foundation-node-${count.index + 1}"
  location = "${var.region}"
  resource_group_name = "${var.resource_group}"
  network_interface_ids = [
    "${element(azurerm_network_interface.foundation_netif.*.id, count.index)}"]
  # vm_size = "Standard_A0"
  vm_size = "Standard_F2"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "16.04.0-LTS"
    version = "latest"
  }

  storage_os_disk {
    name = "${var.organization}-${var.project}-${var.environment}-foundation-osdisk-${count.index + 1}"
    vhd_uri = "${var.foundation_storage_uri}/${var.organization}-${var.project}-${var.environment}-foundation-osdisk-${count.index + 1}.vhd"
    caching = "ReadWrite"
    create_option = "FromImage"
    disk_size_gb = 8
  }

  os_profile {
    computer_name = "${var.organization}-${var.project}-${var.environment}-foundation-node-${count.index + 1}"
    admin_username = "testadmin"
    admin_password = "Password1234!"
    custom_data = "${base64encode(file("cloud-init.txt"))}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/testadmin/.ssh/authorized_keys"
      key_data = "${file("/Users/leow/.ssh/id_rsa.pub")}"
    }
  }

  # For dev setup; don't even bother with Availability Sets
  availability_set_id = "${(var.foundation_servers * 1 > 1) ? azurerm_availability_set.foundation_aset.id : ""}"

  tags {
    type = "Foundation"
  }
}

