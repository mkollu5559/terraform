provider "azurerm" {
  features {}
}

resource "azurerm_policy_definition" "trusted_registry_policy" {
  name         = "trusted-container-registries-policy"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Enforce Trusted Container Registries"
  description  = "Ensures container images are pulled from trusted registries."
  
  policy_rule = <<POLICY_RULE
  {
    "if": {
      "allOf": [
        {
          "field": "type",
          "equals": "Microsoft.ContainerRegistry/registries"
        },
        {
          "field": "Microsoft.ContainerRegistry/registries/loginServer",
          "notIn": [
            "mytrustedregistry.azurecr.io",
            "anothertrustedregistry.azurecr.io"
          ]
        }
      ]
    },
    "then": {
      "effect": "Deny"
    }
  }
  POLICY_RULE

  metadata = <<METADATA
  {
    "category": "Kubernetes"
  }
  METADATA
}

resource "azurerm_policy_assignment" "trusted_registry_assignment" {
  name                 = "trusted-container-registries-assignment"
  scope                = azurerm_kubernetes_cluster.example.id
  policy_definition_id = azurerm_policy_definition.trusted_registry_policy.id
}
