provider "azurerm" {
  features {}
}

# Define the custom role for App Registration Read
resource "azurerm_role_definition" "app_registration_reader" {
  name        = "App Registration Reader"
  scope       = "/"
  description = "Allows read-only access to Azure AD application registrations."

  permissions {
    actions = [
      "microsoft.directory/applications/standard/read",
      "microsoft.directory/applications/basic/read"
    ]
    not_actions = []
  }

  assignable_scopes = [
    "/"
  ]
}

# Assign the role to a user
resource "azurerm_role_assignment" "assign_reader_role" {
  scope              = "/"
  role_definition_id = azurerm_role_definition.app_registration_reader.role_definition_resource_id
  principal_id       = "USER_OR_SERVICE_PRINCIPAL_ID"
}
