terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
    client_id       = var.client_id
    client_secret   = var.client_secret
    subscription_id = var.subscription_id
    tenant_id       = var.tenant_id
}

resource "azurerm_resource_group" "aks_rg" {
  name = "eshop-aks-resource-group"
  location = "southcentralus"
}

resource "azurerm_container_registry" "aks_container_registry" {
  name = "eshopContainerRegistryXYZ"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location = "southcentralus"
  sku = "Basic"
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name = "eshop-single-node-aks"
  location = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix = "eshop-single-node-aks"

  default_node_pool {
    name = "default"
    node_count = 2
    vm_size = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control_enabled = true

  tags = {
    Environment = "Dev"
  }
}

resource "azurerm_role_assignment" "acr_pull" {
  scope = azurerm_container_registry.aks_container_registry.id
  role_definition_name = "ACRPull"
  principal_id = azurerm_kubernetes_cluster.aks_cluster.identity[0].principal_id
  depends_on = [ azurerm_kubernetes_cluster.aks_cluster ]
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_config_raw
  sensitive = true
}

output "acr_login_server" {
  value = azurerm_container_registry.aks_container_registry.login_server
}