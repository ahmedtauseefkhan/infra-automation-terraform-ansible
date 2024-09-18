provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
  subscription_id = "28e1e42a-4438-4c30-9a5f-7d7b488fd883"

}

# Resource Group
data "azurerm_resource_group" "existing" {
  name = "1-9d72f5b5-playground-sandbox"
}

# Virtual Network (VNet)
resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
}

# Subnet
resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = data.azurerm_resource_group.existing.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP Address
resource "azurerm_public_ip" "example" {
  name                = "example-pip"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  allocation_method   = "Static"  
  sku                 = "Standard"
}

# Network Interface
resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "example" {
  name                = "example-vm"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"

  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub") # Replace with your SSH public key path
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name  = "examplevm"
  disable_password_authentication = true
}

# Output the Public IP of the VM
output "public_ip_address" {
  value = azurerm_public_ip.example.ip_address
}
