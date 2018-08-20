variable "resourcename" {
  default = "puppetmasterResourceGroup"
}

# Configure the Microsoft Azure Provider
provider "azurerm" {}

# Create a resource group if it doesn’t exist
# Houses the domain name, virtual machine and virtual network
resource "azurerm_resource_group" "puppetmasterterraformgroup" {
  name     = "puppetmasterResourceGroup"
  location = "eastus"

  tags {
    environment = "Puppet Master"
  }
}

# Create virtual network (like AWS VPC)
resource "azurerm_virtual_network" "puppetmasterterraformnetwork" {
  name                = "puppetmasterVnet"
  address_space       = ["10.0.0.0/16"]
  location            = "eastus"
  resource_group_name = "${azurerm_resource_group.puppetmasterterraformgroup.name}"

  tags {
    environment = "Puppet Master"
  }
}

# Create subnet
resource "azurerm_subnet" "puppetmasterterraformsubnet" {
  name                 = "puppetmasterSubnet"
  resource_group_name  = "${azurerm_resource_group.puppetmasterterraformgroup.name}"
  virtual_network_name = "${azurerm_virtual_network.puppetmasterterraformnetwork.name}"
  address_prefix       = "10.0.1.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "puppetmasterterraformpublicip" {
  name                         = "puppetmasterPublicIP"
  location                     = "eastus"
  resource_group_name          = "${azurerm_resource_group.puppetmasterterraformgroup.name}"
  public_ip_address_allocation = "dynamic"

  tags {
    environment = "Puppet Master"
  }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "puppetmasterterraformnsg" {
  name                = "puppetmasterNetworkSecurityGroup"
  location            = "eastus"
  resource_group_name = "${azurerm_resource_group.puppetmasterterraformgroup.name}"

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags {
    environment = "Puppet Master"
  }
}

# Create network interface
resource "azurerm_network_interface" "puppetmasterterraformnic" {
  name                      = "puppetmasterNIC"
  location                  = "eastus"
  resource_group_name       = "${azurerm_resource_group.puppetmasterterraformgroup.name}"
  network_security_group_id = "${azurerm_network_security_group.puppetmasterterraformnsg.id}"

  ip_configuration {
    name                          = "puppetmasterNicConfiguration"
    subnet_id                     = "${azurerm_subnet.puppetmasterterraformsubnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.puppetmasterterraformpublicip.id}"
  }

  tags {
    environment = "Puppet Master"
  }
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = "${azurerm_resource_group.puppetmasterterraformgroup.name}"
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "puppetmasterstorageaccount" {
  name                     = "diag${random_id.randomId.hex}"
  resource_group_name      = "${azurerm_resource_group.puppetmasterterraformgroup.name}"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags {
    environment = "Puppet Master"
  }
}

# Create virtual machine
resource "azurerm_virtual_machine" "puppetmasterterraformvm" {
  name                  = "puppetmasterVM"
  location              = "eastus"
  resource_group_name   = "${azurerm_resource_group.puppetmasterterraformgroup.name}"
  network_interface_ids = ["${azurerm_network_interface.puppetmasterterraformnic.id}"]
  vm_size               = "Standard_DS1_v2"

  storage_os_disk {
    name              = "puppetmasterOsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "puppetmastervm"
    admin_username = "azureuser"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"
      key_data = "${var.public_key}"
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = "${azurerm_storage_account.puppetmasterstorageaccount.primary_blob_endpoint}"
  }

  tags {
    environment = "Puppet Master"
  }
}
