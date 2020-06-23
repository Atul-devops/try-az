provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = "=2.0.0"
  features {}
}


#======================================
#       Azure RESOURCE GRPS
#======================================
 
resource "azurerm_resource_group" "rg" {
  name     = var.azurerm_resource_group
  location = var.location
 
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
    resource_group_name = azurerm_resource_group.rg.name	
    location            = azurerm_resource_group.rg.location	
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
    security_rule {	
        name                        = "Inbound-allow-7717"	
        priority                    = 1001	
        access                      = "Allow"	
        direction                   = "Inbound"	
        destination_port_range      = 7717	
        protocol                    = "Tcp"	
        source_port_range           = "*"	
        source_address_prefix       = "*"	
        destination_address_prefix  = "*"	
    }	

        security_rule {	
        name                        = "Inbound-allow-5986"	
        priority                    = 1004	
        access                      = "Allow"	
        direction                   = "Inbound"	
        destination_port_range      = 5986	
        protocol                    = "Tcp"	
        source_port_range           = "*"	
        source_address_prefix       = "*"	
        destination_address_prefix  = "*"	
    }
    security_rule {	
        name                        = "Outbound-allow-5282"	
        priority                    = 1002	
        access                      = "Allow"	
        direction                   = "Outbound"	
        destination_port_range      = 5282	
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
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = var.vnet_address_space
  }
 
 
#--- Subnet ----
resource "azurerm_subnet" "internal" {
  name                 = "lonosubnet"
  resource_group_name  =  azurerm_resource_group.rg.name
  virtual_network_name =  azurerm_virtual_network.testnet.name
  address_prefix       =  var.network-subnet-cidr
  }
 
 
#--- Public IP Address ---
resource "azurerm_public_ip" "winpublicip" {
  name                = "WinPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  domain_name_label = "scpclient1510-dns"
  }

 
#--- NIC
resource "azurerm_network_interface" "WindowsNIC" {
  name                = "interface0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
 
  ip_configuration {
    name                          = "QADHCP"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.winpublicip.id
  }
 
}
 
#=================================
#            NODES
#=================================
 
 
## Windows reference system ##
resource "azurerm_virtual_machine" "win10autoclient" {
 
    name                           = "Win10"
    location                       = var.location
    resource_group_name            = azurerm_resource_group.rg.name
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
 
 
 
