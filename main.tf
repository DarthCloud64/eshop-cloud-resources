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
  name = "aks-resource-group"
  location = "southcentralus"
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name = "single-node-aks"
  location = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix = "single-node-aks"

  default_node_pool {
    name = "default"
    node_count = 1
    vm_size = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Dev"
  }
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_config_raw
  sensitive = true
}