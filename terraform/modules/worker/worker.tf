# Main Virtual Network  is known and passed in

# Availability sets always there; could not figure out otherwise
resource "azurerm_availability_set" "worker_aset" {
  count = 1
  name = "${var.organization}-${var.project}-${var.environment}-worker-aset"
  location = "${var.region}"
  resource_group_name = "${var.resource_group}"
}

# Subnets as per defined; Directors start at xx.xx.50.yy
resource "azurerm_subnet" "worker_subnet" {
  count = "${var.num_servers * 1 > 1 ? 3 : 1}"

  name = "${var.organization}-${var.project}-${var.environment}-worker-subnet-${count.index + 1}"
  resource_group_name = "${var.foundation_resource_group}"

  virtual_network_name = "${var.virtual_network}"
  # address_prefix = "${element(var.foundation_subnets, count.index)}"
  address_prefix = "${cidrsubnet(var.cidr_block, 8, 100 + count.index + 1)}"

  # HOWTO security; here??
  # network_security_group_id = ""
  # WAN routing next time?
  # route_table_id = ""

  # In order to prevent something like: https://github.com/hashicorp/terraform/issues/7153
  # Also will need to add dependency on security group once that is added here
  #     IFF it appears >= TF 0.8.x ..
  # depends_on = ["azurerm_virtual_network.foundation_vnet"]
}

# Public IP - No

# Network interfaces for each defined subnets
resource "azurerm_network_interface" "worker_netif" {
  count = "${var.num_servers}"

  name = "${var.organization}-${var.project}-${var.environment}-worker-netif-${count.index + 1}"
  resource_group_name = "${var.resource_group}"
  location = "${var.region}"

  ip_configuration {
    name = "ipconf-${count.index + 1}"
    subnet_id = "${element(azurerm_subnet.worker_subnet.*.id, count.index)}"
    private_ip_address_allocation = "dynamic"
  }

  # Primary node more liberal; the rest lock down?
  # network_security_group_id = ""
  internal_dns_name_label = "${var.organization}-${var.project}-${var.environment}-worker-node-${count.index + 1}"
  enable_ip_forwarding = true

  tags {
    type = "Worker"
  }

}

# Next; setup the virtual_machines
resource "azurerm_virtual_machine" "worker_node" {
  count = "${var.num_servers}"
  name = "${var.organization}-${var.project}-${var.environment}-worker-node-${count.index + 1}"
  location = "${var.region}"
  resource_group_name = "${var.resource_group}"
  network_interface_ids = [
    "${element(azurerm_network_interface.worker_netif.*.id, count.index)}"]
  # vm_size = "Standard_A0"
  vm_size = "${var.instance_type}"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "16.04.0-LTS"
    version = "latest"
  }

  storage_os_disk {
    name = "${var.organization}-${var.project}-${var.environment}-worker-osdisk-${count.index + 1}"
    vhd_uri = "${var.storage_uri}/${var.organization}-${var.project}-${var.environment}-worker-osdisk-${count.index + 1}.vhd"
    caching = "ReadWrite"
    create_option = "FromImage"
    # Min size is 30GB :(
    disk_size_gb = 60
  }

  os_profile {
    computer_name = "${var.organization}-${var.project}-${var.environment}-worker-node-${count.index + 1}"
    admin_username = "testadmin"
    admin_password = "Password1234!"
    custom_data = "${base64encode(file("worker-cloud-init.txt"))}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/testadmin/.ssh/authorized_keys"
      key_data = "${file(var.pub_key)}"
    }
  }

  # For dev setup; don't even bother with Availability Sets
  availability_set_id = "${(var.num_servers * 1 > 1) ? azurerm_availability_set.worker_aset.id : ""}"

  tags {
    type = "Worker"
  }
}

