output "vm_details" {
  description = "Summary of deployed VMs across all environments."
  value = {
    for env, vm in azurerm_linux_virtual_machine.vm : env => {
      resource_group = azurerm_resource_group.rg[env].name
      vm_id          = vm.id
      private_ip     = azurerm_network_interface.nic[env].private_ip_address
      public_ip      = azurerm_public_ip.pip[env].ip_address
      ssh_command    = "ssh ${var.environments[env].admin_username}@${azurerm_public_ip.pip[env].ip_address}"
    }
  }
}