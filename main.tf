#======================================
#       Azure RESOURCE GRPS
#======================================
 
resource "azurerm_resource_group" "win-rm" {
  name     = "win-rm"
  location = "West US"
 
  tags = {
    CreatedBy = "Azad",
    Purpose   = "testing"
  }
 
}
 
#====================================
#          NSG
#===================================
# Network Security Group with allow RDP rule 
resource "azurerm_network_security_group" "ansg-01" {
    name                = "test-nsg"
    resource_group_name = azurerm_resource_group.win-rm.name
    location            = azurerm_resource_group.win-rm.location
    security_rule {
        name                        = "default-allow-3389"
        priority                    = 1000
        access                      = "Allow"
        direction                   = "Inbound"
        destination_port_range      = 3389
        protocol                    = "Tcp"
        source_port_range           = "*"
        source_address_prefix       = "*"
        destination_address_prefix  = "*"
    }
}
 
#=====================================
#           NETWORK
#=====================================
 
resource "azurerm_virtual_network" "testnet" {
  name                = "testnet"
  resource_group_name = azurerm_resource_group.win-rm.name
  location            = azurerm_resource_group.win-rm.location
  address_space       = ["10.1.10.0/24"]
  }
 
 
#--- Subnet ----
resource "azurerm_subnet" "internal" {
  name                 = "lonosubnet"
  resource_group_name  =  azurerm_resource_group.win-rm.name
  virtual_network_name =  azurerm_virtual_network.testnet.name
  address_prefixes       = ["10.1.10.0/24"]
  }
 
 
#--- Public IP Address ---
resource "azurerm_public_ip" "WinPublicIP" {
  name                = "WinPublicIP"
  location            = azurerm_resource_group.win-rm.location
  resource_group_name = azurerm_resource_group.win-rm.name
  allocation_method   = "Static"
  }
 
 
#--- NIC
resource "azurerm_network_interface" "WindowsNIC" {
  name                = "interface0"
  location            = azurerm_resource_group.win-rm.location
  resource_group_name = azurerm_resource_group.win-rm.name
 
  ip_configuration {
    name                          = "QADHCP"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.WinPublicIP.id
  }
 
}
 
#=================================
#            NODES
#=================================
 
 
## Windows reference system ##
resource "azurerm_virtual_machine" "win10autoclient" {
 
    name                           = "Win10"
    location                       = "West US"
    resource_group_name            = azurerm_resource_group.win-rm.name
    network_interface_ids          = [azurerm_network_interface.WindowsNIC.id]
    vm_size                        = var.vmSize
    delete_os_disk_on_termination  = "true"
 
 
#--- Base OS Image ---
   storage_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = var.windowsOSVersion
    version   = "latest"
  }
 
 
#--- Disk Storage Type
 
  storage_os_disk {
    name              = "disk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    os_type           = "Windows"
  }
  storage_data_disk {
    name            = "Data"
    disk_size_gb    = 1023
    lun             = 0
    create_option   = "Empty"
    }
 
 
#--- Define password + hostname ---
  os_profile {
    computer_name   = "Win10"
    admin_username  = var.adminUsername
    admin_password  = var.adminPassword
  }
 
#---
 
  os_profile_windows_config {
    enable_automatic_upgrades = true
    provision_vm_agent = true
  }
 
#-- Windows VM Diagnostics 
 

#--- VM Tags
 
  tags = {
    environment = "Dev"
  }
 
 
 
#--- Post Install Provisioning ---
 
 
 
}
 
 
 
