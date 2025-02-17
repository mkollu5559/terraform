provider "azuread" {}

# Fetch Microsoft Graph API details
data "azuread_application_published_app_ids" "well_known" {}

data "azuread_service_principal" "graph" {
  application_id = data.azuread_application_published_app_ids.well_known.result["MicrosoftGraph"]
}

data "azuread_service_principal_delegated_permission" "user_read" {
  service_principal_id = data.azuread_service_principal.graph.object_id
  claim_value          = "User.Read.All"
}

# Create an Azure AD Application Registration
resource "azuread_application" "v1_1_app" {
  display_name = "V1.1 Monitoring Integration"
}

# Assign Read Scope (Role Assignment)
resource "azuread_application_app_role" "read_scope" {
  application_object_id = azuread_application.v1_1_app.object_id
  allowed_member_types  = ["User"]
  description           = "Allows reading V1.1 components"
  display_name         = "Read V1.1 Components"
  id                   = uuid()
  value                = "ReadV1.1"
}

# Grant API Permissions dynamically
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
