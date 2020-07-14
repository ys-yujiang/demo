# Azure Subscription Id
variable "azure-subscription-id" {
    type        = string
    description = "Azure Subscription Id"
    default = "test"
}
#Azure Client Id/appId
variable "azure-client-id" {
    type        = string
    description = "Azure Client Id/appId"
    default = "test"
}
# Azure Client Id/appId
variable "azure-client-secret" {
    type        = string
    description = "Azure Client Id/appId"
    default = "test"
}
# Azure Tenant Id
variable "azure-tenant-id" {
    type        = string
    description = "Azure Tenant Id"
    default = "test"
}

provider "azurerm" { 
#    subscription_id = var.azure-subscription-id
#    client_id       = var.azure-client-id
#    client_secret   = var.azure-client-secret 
#    tenant_id       = var.azure-tenant-id
    version = "=2.0.0"
    features {}
}

variable "prefix" {
  default = "vmware-gadagip-test"
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-resources"
  location = "East US"
}

resource "azurerm_virtual_network" "vn" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "ni" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.ni.id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "dev"
  }
}