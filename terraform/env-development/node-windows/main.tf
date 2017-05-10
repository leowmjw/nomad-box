# Main Terraform
terraform {
  required_version = "> 0.9.0"
}

# Variables + Providers
variable "num_servers" {
  default = 1
}

provider "azurerm" {
  subscription_id = "${var.azure_subscription_id}"
  client_id = "${var.azure_client_id}"
  client_secret = "${var.azure_client_secret}"
  tenant_id = "${var.azure_tenant_id}"
}

# Remote state from local existing Nomad Box Environment
data "terraform_remote_state" "nomadbox" {
  backend = "local"

  config {
    path = "/Users/leow/Desktop/PROJECTS/DEVOPS/nomad-box/terraform/env-development/terraform.tfstate"
  }
}

# Resource Definitions
resource "azurerm_availability_set" "windows_aset" {
  count = 1
  name = "${var.organization}-${var.project}-${var.environment}-windows-aset"
  location = "${data.terraform_remote_state.nomadbox.resource_group_location}"
  resource_group_name = "${data.terraform_remote_state.nomadbox.resource_group_name}"
}

# Subnets as per defined; Directors start at xx.xx.66.yy
resource "azurerm_subnet" "windows_subnet" {
  count = "${var.num_servers * 1 > 1 ? 3 : 1}"

  name = "${var.organization}-${var.project}-${var.environment}-windows-subnet-${count.index + 1}"
  resource_group_name = "${data.terraform_remote_state.nomadbox.resource_group_name}"

  virtual_network_name = "${data.terraform_remote_state.nomadbox.virtual_network}"
  # address_prefix = "${element(var.foundation_subnets, count.index)}"
  address_prefix = "${cidrsubnet(var.cidr_block, 8, 65 + count.index + 1)}"

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
resource "azurerm_network_interface" "windows_netif" {
  count = "${var.num_servers}"

  name = "${var.organization}-${var.project}-${var.environment}-windows-netif-${count.index + 1}"
  resource_group_name = "${data.terraform_remote_state.nomadbox.resource_group_name}"
  location = "${data.terraform_remote_state.nomadbox.resource_group_location}"

  ip_configuration {
    name = "ipconf-${count.index + 1}"
    subnet_id = "${element(azurerm_subnet.windows_subnet.*.id, count.index)}"
    private_ip_address_allocation = "dynamic"
  }

  # Primary node more liberal; the rest lock down?
  # network_security_group_id = ""
  # Trademark name .. boo hiss .. windows ...
  # Status=400 Code="DomainNameLabelReserved" Message="The domain name label acme-nomad-dev-windows-node-1 is invalid.
  # The name itself or part of the name is a reserved word such as a trademark. Please use a different name."
  internal_dns_name_label = "${var.organization}-${var.project}-${var.environment}-winzzz-node-${count.index + 1}"
  enable_ip_forwarding = true

  tags {
    type = "Windows"
  }
}

# Next; setup the virtual_machines
resource "azurerm_virtual_machine" "windows_node" {
  count = "${var.num_servers}"
  name = "${var.organization}-${var.project}-${var.environment}-windows-node-${count.index + 1}"
  resource_group_name = "${data.terraform_remote_state.nomadbox.worker_resource_group_name}"
  location = "${data.terraform_remote_state.nomadbox.resource_group_location}"
  network_interface_ids = [
    "${element(azurerm_network_interface.windows_netif.*.id, count.index)}"]
  # vm_size = "Standard_A0"
  vm_size = "${var.windows_distribution["instance_type"]}"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer = "${var.windows_distribution["offer"]}"
    sku = "${var.windows_distribution["sku"]}"
    version = "latest"
  }

  storage_os_disk {
    name = "${var.organization}-${var.project}-${var.environment}-windows-osdisc-${count.index + 1}"
    vhd_uri = "${data.terraform_remote_state.nomadbox.storage_uri}/${var.organization}-${var.project}-${var.environment}-windows-osdisk-${count.index + 1}.vhd"
    caching = "ReadWrite"
    create_option = "FromImage"
    # Min size is 30GB :(
    // Windows give you 130GB; can;t reduce it :(
    disk_size_gb = 130
  }

  os_profile {
    // Computer name has a limit of 15 chars ... booo .. hiss..
    computer_name = "Winzzz-${count.index + 1}-${var.environment}"
    admin_username = "testadmin"
    admin_password = "!TestAdmin123456"
    custom_data = "${base64encode(file("windows-cloud-init.txt"))}"
  }

  os_profile_windows_config {
    // Below needed to install Extensions
    provision_vm_agent = true
    enable_automatic_upgrades = true
    winrm {
      protocol = "http"
    }
    /*
    additional_unattend_config {}
    */
  }

  # For dev setup; don't even bother with Availability Sets
  availability_set_id = "${(var.num_servers * 1 > 1) ? azurerm_availability_set.windows_aset.id : ""}"

  // Needed if has booting up trouble ..?
  // boot_diagnostics {}

  tags {
    type = "Windows"
  }
}

/*
resource "null_resource" "winrm" {

    connection {
        type = "winrm"
        user = "testadmin"
        password = "Password1234!"
        insecure = true
        host = "10.0.3.4"
    }

       provisioner "remote-exec" {
        inline = [
          "powershell mkdir /opt",
          "powershell cp /AzureData/* /opt/."
        ]
    }

}
*/

resource "azurerm_storage_blob" "windows_cloudinit" {
  // One script only; maybe only if customization or maybe for Nano Server will be different?
  count = 1
  name = "${var.organization}-${var.project}-${var.environment}-NomadBoxCloudInit.ps1"
  resource_group_name = "${data.terraform_remote_state.nomadbox.resource_group_name}"
  storage_account_name = "${data.terraform_remote_state.nomadbox.storage_account_name}"
  storage_container_name = "${data.terraform_remote_state.nomadbox.storage_container_name}"
  // type = "page"
  // Absolute path ..
  // source = "/Users/leow/..."
  source_uri = "https://raw.githubusercontent.com/Microsoft/dotnet-core-sample-templates/master/dotnet-core-music-windows/scripts/configure-music-app.ps1"
  attempts = 3
}

resource "azurerm_virtual_machine_extension" "windows_extension" {
  count = "${var.num_servers}"
  name = "${var.organization}-${var.project}-${var.environment}-windows-ext-${count.index + 1}"
  resource_group_name = "${data.terraform_remote_state.nomadbox.worker_resource_group_name}"
  location = "${data.terraform_remote_state.nomadbox.resource_group_location}"
  publisher = "Microsoft.Compute"
  type = "CustomScriptExtension"
  type_handler_version = "1.8"
  virtual_machine_name = "${element(azurerm_virtual_machine.windows_node.*.name, count.index)}"
  auto_upgrade_minor_version = "true"

  settings = <<SETTINGS
  {
        "fileUris": [ "https://raw.githubusercontent.com/leowmjw/nomad-box/master/terraform/env-development/windows-cloud-init.ps1" ]
  }
SETTINGS
  /* Storage node needs to be public!!
  settings = <<SETTINGS
  {
        "fileUris": [ "${data.terraform_remote_state.nomadbox.storage_uri}/${var.organization}-${var.project}-${var.environment}-NomadBoxCloudInit.ps1" ]
  }
SETTINGS
*/

  // If below pass any sensitive items will not appear in the Terraform plan output :P
  protected_settings = <<PROTECT_SETTINGS
  {
        "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File windows-cloud-init.ps1"
  }
PROTECT_SETTINGS
  // Make it dependent on a provisioning upload to location for storage??
  depends_on = [
    "azurerm_storage_blob.windows_cloudinit"
  ]
}