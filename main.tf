# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "pr-rg" {
  name     = "dev-vm-rg"
  location = var.location

  tags = {
    environment = "dev-vm"
  }
}

resource "azurerm_virtual_network" "pr-vn" {
  name                = "dev-vm-vn"
  resource_group_name = azurerm_resource_group.pr-rg.name
  location            = azurerm_resource_group.pr-rg.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "dev-vm"
  }
}

resource "azurerm_subnet" "pr-snet" {
  name                 = "dev-vm-snet"
  resource_group_name  = azurerm_resource_group.pr-rg.name
  virtual_network_name = azurerm_virtual_network.pr-vn.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "pr-sg" {
  name                = "dev-vm-sg"
  location            = azurerm_resource_group.pr-rg.location
  resource_group_name = azurerm_resource_group.pr-rg.name

  tags = {
    environment = "dev-vm"
  }
}

resource "azurerm_network_security_rule" "pr-sr" {
  name                        = "dev-vm-sr"
  resource_group_name         = azurerm_resource_group.pr-rg.name
  network_security_group_name = azurerm_network_security_group.pr-sg.name
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_subnet_network_security_group_association" "pr-sga" {
  subnet_id                 = azurerm_subnet.pr-snet.id
  network_security_group_id = azurerm_network_security_group.pr-sg.id
}

resource "azurerm_public_ip" "pr-ip" {
  name                    = "dev-vm-pip"
  location                = azurerm_resource_group.pr-rg.location
  resource_group_name     = azurerm_resource_group.pr-rg.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

  tags = {
    environment = "dev-vm"
  }
}

resource "azurerm_network_interface" "pr-nic" {
  name                = "dev-vm-nic"
  location            = azurerm_resource_group.pr-rg.location
  resource_group_name = azurerm_resource_group.pr-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.pr-snet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pr-ip.id
  }

  tags = {
    environment = "dev-vm"
  }
}

resource "azurerm_linux_virtual_machine" "pr-vm" {
  name                  = "dev-vm-vm"
  location              = azurerm_resource_group.pr-rg.location
  resource_group_name   = azurerm_resource_group.pr-rg.name
  size                  = "Standard_B1s"
  admin_username        = "adminuser"
  network_interface_ids = [azurerm_network_interface.pr-nic.id]

  custom_data = filebase64("customdata.sh")

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
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

  provisioner "local-exec" {
    command = templatefile("os_files/${var.host_os}-ssh-script.in", {
      hostname     = self.public_ip_address,
      user         = "adminuser",
      identityfile = "~/.ssh/id_rsa"
    })
    interpreter = var.host_os == "windows" ? ["Powershell", "-Command"] : ["bash", "-c"]
  }

  tags = {
    environment = "dev-vm"
  }
}

data "azurerm_public_ip" "pr-ip-data" {
  name                = azurerm_public_ip.pr-ip.name
  resource_group_name = azurerm_resource_group.pr-rg.name
}

output "instance_ip_address" {
  value = "${azurerm_linux_virtual_machine.pr-vm.name}: ${data.azurerm_public_ip.pr-ip-data.ip_address}"
}
