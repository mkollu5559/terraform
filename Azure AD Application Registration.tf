provider "azuread" {}

# Fetch Microsoft Graph API service principal
data "azuread_service_principal" "graph" {
  display_name = "Microsoft Graph"
}

# Fetch the permission ID for "User.Read.All"
data "azuread_service_principal_delegated_permission" "user_read" {
  service_principal_id = data.azuread_service_principal.graph.object_id
  claim_value          = "User.Read.All"
}

# Create an Azure AD Application Registration
resource "azuread_application" "v1_1_app" {
  display_name = "V1.1 Monitoring Integration"
}

# Grant API Permissions dynamically (No Hardcoding)
resource "azuread_application_api_permission" "graph_read" {
  application_object_id = azuread_application.v1_1_app.object_id
  api_client_id         = data.azuread_service_principal.graph.application_id
  permission_ids        = [data.azuread_service_principal_delegated_permission.user_read.id]
  type                 = "Application"
}

# Output values
output "app_id" {
  value = azuread_application.v1_1_app.client_id
}

output "object_id" {
  value = azuread_application.v1_1_app.object_id
}
