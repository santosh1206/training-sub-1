environments = {
  dev = {
    location            = "eastus"
    resource_group_name = "rg-dev-workload"
    vnet_cidr           = "10.10.0.0/16"
    subnet_cidr         = "10.10.1.0/24"
    vm_size             = "Standard_B1s"
    admin_password      = "DevPass1234#!"
    data_disk_size_gb   = 32
    tags = {
      Environment = "Development"
      CostCenter  = "Dev-101"
    }
  }

  qa = {
    location            = "eastus"
    resource_group_name = "rg-qa-workload"
    vnet_cidr           = "10.20.0.0/16"
    subnet_cidr         = "10.20.1.0/24"
    vm_size             = "Standard_B2s"
    admin_password      = "QaPass1234#!"
    data_disk_size_gb   = 64
    tags = {
      Environment = "QA"
      CostCenter  = "QA-201"
    }
  }

  prod = {
    location            = "eastus"
    resource_group_name = "rg-prod-workload"
    vnet_cidr           = "10.30.0.0/16"
    subnet_cidr         = "10.30.1.0/24"
    vm_size             = "Standard_D2s_v5"
    admin_password      = "ProdPass9876#!"
    os_disk_type        = "Premium_LRS"
    os_disk_size_gb     = 64
    data_disk_size_gb   = 128
    data_disk_type      = "Premium_LRS"
    tags = {
      Environment = "Production"
      CostCenter  = "Prod-301"
    }
  }
}