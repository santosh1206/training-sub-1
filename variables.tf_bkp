variable "environments" {
  description = "Map of environment configurations for deploying Resource Groups and Linux VMs."
  type = map(object({
    location            = string
    resource_group_name = string
    vnet_cidr           = string
    subnet_cidr         = string
    vm_size             = optional(string, "Standard_B2s")
    admin_username      = optional(string, "azureuser")
    admin_password      = string
    os_disk_caching     = optional(string, "ReadWrite")
    os_disk_type        = optional(string, "Premium_LRS")
    os_disk_size_gb     = optional(number, 30)
    data_disk_size_gb   = optional(number, 64)
    data_disk_type      = optional(string, "Premium_LRS")
    tags                = optional(map(string), {})
  }))
}