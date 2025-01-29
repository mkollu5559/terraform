provider "azurerm" {
  features {}
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "myAKSCluster"
  location            = "East US"
  resource_group_name = "myResourceGroup"
  dns_prefix          = "myaks"

  default_node_pool {
    name       = "agentpool"
    node_count = 2
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_policy_definition" "allowed_images" {
  name         = "kubernetes-allowed-images"
  policy_type  = "Custom"
  mode         = "Microsoft.Kubernetes"
  display_name = "Allowed Container Images"

  metadata = <<METADATA
    {
      "category": "Kubernetes"
    }
  METADATA

  policy_rule = <<POLICY_RULE
    {
      "if": {
        "allOf": [
          {
            "field": "kubernetes.pod.spec.containers[*].image",
            "notMatchInsensitively": "^(${join("|", [
              "crnovaxregistryshared\\.azurecr\\.io",
              "docker\\.io/bitnami",
              "ghcr\\.io",
              "registry\\.k8s\\.io",
              "quay\\.io/jetstack"
            ])}).*"
          }
        ]
      },
      "then": {
        "effect": "Deny"
      }
    }
  POLICY_RULE
}

resource "azurerm_policy_assignment" "allowed_images_assignment" {
  name                 = "allowed-images-assignment"
  policy_definition_id = azurerm_policy_definition.allowed_images.id
  scope                = azurerm_kubernetes_cluster.aks.id
}
