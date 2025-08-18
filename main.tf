#######################
# Provider
#######################
provider "azurerm" {
  features {}
}

#######################
# Resource Group
#######################
resource "azurerm_resource_group" "rg" {
  name     = "rg-private-vm"
  location = "East US"
}

#######################
# Virtual Network
#######################
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-private"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

#######################
# Subnet
#######################
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-private"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

#######################
# Network Security Group
#######################
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-private"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Example rule: Allow SSH only from VNet
resource "azurerm_network_security_rule" "ssh" {
  name                        = "Allow-SSH-VNet"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "10.0.0.0/16"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

#######################
# Network Interface (NO Public IP)
#######################
resource "azurerm_network_interface" "nic" {
  name                = "nic-private"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    # NOTE: No public_ip_address_id here → private only
  }
}

#######################
# Linux VM
#######################
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "private-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  disable_password_authentication = true
}
