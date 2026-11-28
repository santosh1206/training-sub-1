resource "azurerm_resource_group" "aks" {
  name     = var.resource_group_name
  location = var.location
}
##Add Aks Cluster
# 1. VNet & Node Subnet (Sized /22 for Classic Azure CNI IP allocation)
resource "azurerm_virtual_network" "aks" {
  name                = "vnet-aks-prod"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  address_space       = ["10.240.0.0/16"]
}

resource "azurerm_subnet" "aks_nodes" {
  name                 = "snet-aks-nodes"
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.aks.name
  address_prefixes     = ["10.240.0.0/22"]
}

# 2. AKS Cluster with Classic Azure CNI + System Node Pool (agentpool)
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = "aksprod"
  kubernetes_version  = var.kubernetes_version
  node_resource_group = "MC_${var.resource_group_name}_${var.cluster_name}_${var.location}"

  default_node_pool {
    name                        = "agentpool"
    vm_size                     = "Standard_D4ds_v4"
    node_count                  = 1
    vnet_subnet_id              = azurerm_subnet.aks_nodes.id
    max_pods                    = 30
    only_critical_addons_enabled = true # Taints agentpool so only system pods run here

    upgrade_settings {
      max_surge = "1"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  # Classic Azure CNI (No Overlay)
  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    service_cidr      = "10.241.0.0/16"
    dns_service_ip    = "10.241.0.10"
  }
}

# 3. User Node Pool (userpool) backed by VMSS for Application Workloads
resource "azurerm_kubernetes_cluster_node_pool" "userpool" {
  name                  = "userpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_D4ds_v4"
  node_count            = 1
  vnet_subnet_id        = azurerm_subnet.aks_nodes.id
  max_pods              = 30
  mode                  = "User"
  node_taints = ["workload=apps:NoSchedule"]

  node_labels = {
    "workload" = "apps"
  }

  upgrade_settings {
    max_surge = "1"
  }
}

# 4. Grant Network Contributor to AKS System-Assigned Managed Identity
resource "azurerm_role_assignment" "aks_network_contributor" {
  scope                = azurerm_subnet.aks_nodes.id # Or use azurerm_virtual_network.aks.id if AKS manages multiple subnets/route tables
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}
