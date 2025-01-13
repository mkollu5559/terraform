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


provider "azurerm" {
  features {}
}

resource "null_resource" "enable_encryption_at_host" {
  provisioner "local-exec" {
    command = <<EOT
      az feature register --namespace "Microsoft.Compute" --name "EncryptionAtHost"
      az provider register --namespace "Microsoft.Compute"
    EOT
  }
  triggers = {
    always_run = timestamp()
  }
}
terraform import azurerm_resource_provider_registration.compute /subscriptions/<subscription_id>/providers/Microsoft.Compute
