# 1. Resource Group per environment
resource "azurerm_resource_group" "rg" {
  for_each = var.environments

  name     = each.value.resource_group_name
  location = each.value.location
  tags     = each.value.tags
}

# 2. Virtual Network per environment
resource "azurerm_virtual_network" "vnet" {
  for_each = var.environments

  name                = "vnet-${each.key}"
  address_space       = [each.value.vnet_cidr]
  location            = azurerm_resource_group.rg[each.key].location
  resource_group_name = azurerm_resource_group.rg[each.key].name
  tags                = each.value.tags
}

# 3. Subnet per environment
resource "azurerm_subnet" "subnet" {
  for_each = var.environments

  name                 = "snet-${each.key}"
  resource_group_name  = azurerm_resource_group.rg[each.key].name
  virtual_network_name = azurerm_virtual_network.vnet[each.key].name
  address_prefixes     = [each.value.subnet_cidr]
}

# 4. Public IP per environment
resource "azurerm_public_ip" "pip" {
  for_each = var.environments

  name                = "pip-${each.key}-vm"
  location            = azurerm_resource_group.rg[each.key].location
  resource_group_name = azurerm_resource_group.rg[each.key].name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = each.value.tags
}

# 5. Network Security Group per environment
resource "azurerm_network_security_group" "nsg" {
  for_each = var.environments

  name                = "nsg-${each.key}-vm"
  location            = azurerm_resource_group.rg[each.key].location
  resource_group_name = azurerm_resource_group.rg[each.key].name
  tags                = each.value.tags

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# 6. Network Interface per environment
resource "azurerm_network_interface" "nic" {
  for_each = var.environments

  name                = "nic-${each.key}-vm"
  location            = azurerm_resource_group.rg[each.key].location
  resource_group_name = azurerm_resource_group.rg[each.key].name
  tags                = each.value.tags

  ip_configuration {
    name                          = "ipconfig-primary"
    subnet_id                     = azurerm_subnet.subnet[each.key].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip[each.key].id
  }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  for_each = var.environments

  network_interface_id      = azurerm_network_interface.nic[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}

# 7. Linux VM per environment
resource "azurerm_linux_virtual_machine" "vm" {
  for_each = var.environments

  name                            = "vm-${each.key}-01"
  location                        = azurerm_resource_group.rg[each.key].location
  resource_group_name             = azurerm_resource_group.rg[each.key].name
  network_interface_ids           = [azurerm_network_interface.nic[each.key].id]
  size                            = each.value.vm_size
  admin_username                  = each.value.admin_username
  admin_password                  = each.value.admin_password
  disable_password_authentication = false
  tags                            = each.value.tags

  os_disk {
    name                 = "osdisk-${each.key}-01"
    caching              = each.value.os_disk_caching
    storage_account_type = each.value.os_disk_type
    disk_size_gb         = each.value.os_disk_size_gb
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

# 8. Managed Data Disk per environment
resource "azurerm_managed_disk" "data_disk" {
  for_each = var.environments

  name                 = "datadisk-${each.key}-01"
  location             = azurerm_resource_group.rg[each.key].location
  resource_group_name  = azurerm_resource_group.rg[each.key].name
  storage_account_type = each.value.data_disk_type
  create_option        = "Empty"
  disk_size_gb         = each.value.data_disk_size_gb
  tags                 = each.value.tags
}

# 9. Attach Data Disk to VM
resource "azurerm_virtual_machine_data_disk_attachment" "disk_attach" {
  for_each = var.environments

  managed_disk_id    = azurerm_managed_disk.data_disk[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.vm[each.key].id
  lun                = 10
  caching            = "ReadWrite"
}