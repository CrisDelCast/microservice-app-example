terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {} # Provider AzureRM debe declarar features {} para habilitar funcionalidades
}

provider "kubernetes" {
  config_path = var.kubeconfig_path # Ruta a tu kubeconfig local
}

# Resource Group
resource "azurerm_resource_group" "microservices_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_redis_cache" "redis_queue" {
  name                = var.redis_name
  location            = azurerm_resource_group.microservices_rg.location
  resource_group_name = azurerm_resource_group.microservices_rg.name
  capacity            = 2
  family              = "C"
  sku_name            = "Standard"
}

# Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.microservices_rg.name
  location            = azurerm_resource_group.microservices_rg.location
  sku                 = "Standard"
  admin_enabled       = true
}

# Azure Kubernetes Service
resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.aks_name
  location            = azurerm_resource_group.microservices_rg.location
  resource_group_name = azurerm_resource_group.microservices_rg.name
  dns_prefix          = "microservices"

  default_node_pool {
    name       = "default"
    node_count = var.aks_node_count
    vm_size    = var.aks_node_vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control_enabled = true
  network_profile {
    network_plugin = "azure"
  }
}

# API Management
resource "azurerm_api_management" "apim" {
  name                = var.apim_name
  location            = azurerm_resource_group.microservices_rg.location
  resource_group_name = azurerm_resource_group.microservices_rg.name
  publisher_name      = var.apim_publisher_name
  publisher_email     = var.apim_publisher_email
  sku_name            = "Developer_1"
}

# Namespace en Kubernetes
resource "kubernetes_namespace" "microservices" {
  metadata {
    name = var.k8s_namespace
  }
}

# El recurso azurerm_redis_cache.redis_queue ha sido eliminado.
# Si tu aplicación depende de esta instancia de Redis, su eliminación afectará la funcionalidad.
