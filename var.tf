variable "adminUsername" {
    default        = "AzureUser"
    description = " Username for the Virtual Machine."
}

variable "adminPassword" {
    default        = "Welcome@1234567890"
    description = " Password for the Virtual Machine."
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
