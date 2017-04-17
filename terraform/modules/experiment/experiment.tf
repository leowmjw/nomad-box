# Main Virtual Network  is known and passed in

# Availability sets always there; could not figure out otherwise
resource "azurerm_availability_set" "experiment_aset" {
  count = 1
  name = "${var.organization}-${var.project}-${var.environment}-experiment-aset"
  location = "${var.region}"
  resource_group_name = "${var.resource_group}"
}

# Subnets as per defined; experiments start at xx.xx.50.yy
resource "azurerm_subnet" "experiment_subnet" {
  count = "${var.num_servers * 1 > 1 ? 3 : 1}"

  name = "${var.organization}-${var.project}-${var.environment}-experiment-subnet-${count.index + 1}"
  resource_group_name = "${var.foundation_resource_group}"

  virtual_network_name = "${var.virtual_network}"
  # address_prefix = "${element(var.foundation_subnets, count.index)}"
  address_prefix = "${cidrsubnet(var.cidr_block, 8, 41 + count.index + 1)}"

  # HOWTO security; here??
  # network_security_group_id = ""
  # WAN routing next time?
  # route_table_id = ""

  # In order to prevent something like: https://github.com/hashicorp/terraform/issues/7153
  # Also will need to add dependency on security group once that is added here
  #     IFF it appears >= TF 0.8.x ..
  # depends_on = ["azurerm_virtual_network.foundation_vnet"]
}

# Public IP - Yes, since LB -> attach it to Cloudflare etc?
resource "azurerm_public_ip" "experiment_pubip" {
  count = "${var.num_servers}"

  name = "${var.organization}-${var.project}-${var.environment}-experiment-pubip-${count.index + 1}"
  resource_group_name = "${var.resource_group}"
  location = "${var.region}"
  public_ip_address_allocation = "dynamic"
}

# Network interfaces for each defined subnets
resource "azurerm_network_interface" "experiment_netif" {
  count = "${var.num_servers}"

  name = "${var.organization}-${var.project}-${var.environment}-experiment-netif-${count.index + 1}"
  resource_group_name = "${var.resource_group}"
  location = "${var.region}"

  ip_configuration {
    name = "ipconf-${count.index + 1}"
    subnet_id = "${element(azurerm_subnet.experiment_subnet.*.id, count.index)}"
    public_ip_address_id = "${element(azurerm_public_ip.experiment_pubip.*.id, count.index)}"
    private_ip_address_allocation = "dynamic"
  }

  # Primary node more liberal; the rest lock down?
  # network_security_group_id = ""
  internal_dns_name_label = "${var.organization}-${var.project}-${var.environment}-experiment-node-${count.index + 1}"
  enable_ip_forwarding = true

  tags {
    type = "experiment"
  }

}

# Next; setup the virtual_machines
resource "azurerm_virtual_machine" "experiment_node" {
  count = "${var.num_servers}"
  name = "${var.organization}-${var.project}-${var.environment}-experiment-node-${count.index + 1}"
  location = "${var.region}"
  resource_group_name = "${var.resource_group}"
  network_interface_ids = [
    "${element(azurerm_network_interface.experiment_netif.*.id, count.index)}"]
  # vm_size = "Standard_A0"
  vm_size = "${var.instance_type}"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "17.04-DAILY"
    version = "latest"
  }

  storage_os_disk {
    name = "${var.organization}-${var.project}-${var.environment}-experiment-osdisk-${count.index + 1}"
    vhd_uri = "${var.storage_uri}/${var.organization}-${var.project}-${var.environment}-experiment-osdisk-${count.index + 1}.vhd"
    caching = "ReadWrite"
    create_option = "FromImage"
    # Min size is 30GB :(
    # disk_size_gb = 60
  }

  os_profile {
    computer_name = "${var.organization}-${var.project}-${var.environment}-experiment-node-${count.index + 1}"
    admin_username = "testadmin"
    admin_password = "Password1234!"
    custom_data = "${base64encode(file("experiment-cloud-init.txt"))}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/testadmin/.ssh/authorized_keys"
      key_data = "${file(var.pub_key)}"
    }
  }

  # For dev setup; don't even bother with Availability Sets
  availability_set_id = "${(var.num_servers * 1 > 1) ? azurerm_availability_set.experiment_aset.id : ""}"

  tags {
    type = "experiment"
  }


  # Provision by copying over the files neededfor LXD
  # NExt time execute it once find out the correct steps??

  provisioner "file" {
    connection {
      bastion_host = "52.187.114.129"
      bastion_port = "22"
      user = "testadmin"
      # private_key = "${file("/tmp/ssl.key")}"
      agent = "true"
    }
    source = "../../lxd/scripts"
    # First, when using the ssh connection type the destination directory must already exist.
    # If you need to create it, use a remote-exec provisioner just prior to the file provisioner in order to
    # create the directory. Use /tmp first ..
    destination = "/tmp"
  }
  /* Next time execute script with args ..
   provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "/tmp/script.sh args",
    ]
  }
  */
}

