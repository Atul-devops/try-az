variable "adminUsername" {
    default        = "AzureUser"
    description = " Username for the Virtual Machine."
}

variable "adminPassword" {
    default        = "Welcome@1234567890"
    description = " Password for the Virtual Machine."
}

variable "azurerm_resource_group" {
    type    = string
    default    = "win-rm"
    description = "Resouce group name for Azure resources"
 }

 variable "location" {
  type    = string
  default = "West US"
  description = "The default Azure region for the resource provisioning"
}

variable "vmSize" {
    type    = string
    default = "Standard_D2s_v3"
    description = "Size of the virtual machine."
}

variable "windowsOSVersion" {
    type        = string
    default     = "19h1-evd"
    description = "The Windows version for the VM. This will pick a fully patched image of this given Windows version."
}

variable "vnet_address_space" {
  type = list
  description = "The CIDR for the network"
  default = ["10.0.0.0/16"]
}

variable "network-subnet-cidr" {
  type = string
  description = "The CIDR for the network subnet"
  default = "10.0.1.0/24"
}
