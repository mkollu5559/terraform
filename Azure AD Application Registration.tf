# Fetch Microsoft Graph API's application ID dynamically
data "azuread_application_published_app_ids" "well_known" {}

data "azuread_application" "graph" {
  application_id = data.azuread_application_published_app_ids.well_known.result["MicrosoftGraph"]
}

# Fetch Permission ID for "User.Read.All"
data "azuread_service_principal" "graph" {
  object_id = data.azuread_application.graph.object_id
}

data "azuread_service_principal_delegated_permission" "user_read" {
  service_principal_id = data.azuread_service_principal.graph.object_id
  claim_value          = "User.Read.All"
}
resource "azuread_application_api_permission" "graph_read" {
  application_object_id = azuread_application.v1_1_app.object_id
  api_client_id         = data.azuread_application.graph.application_id
  permission_ids        = [data.azuread_service_principal_delegated_permission.user_read.id]
  type                 = "Application"
}
