provider "azurerm" {
  features {}
}

resource "azurerm_subscription_feature" "encryption_at_host" {
  name      = "EncryptionAtHost"
  namespace = "Microsoft.Compute"
}

resource "azurerm_provider_registration" "compute" {
  provider_namespace = "Microsoft.Compute"
}

output "encryption_at_host_status" {
  value = azurerm_subscription_feature.encryption_at_host.state
}
