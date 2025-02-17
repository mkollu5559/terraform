resource "azuread_application" "app" {
  display_name = "my-app-registration"

  api {
    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to read data"
      admin_consent_display_name = "Read access"
      id                         = "read-scope-id"
      is_enabled                 = true
      type                       = "User"
      user_consent_description   = "Allow the application to read your data"
      user_consent_display_name  = "Read access"
      value                      = "read"
    }
  }
}

resource "azuread_app_role_assignment" "role_assignment" {
  app_role_id         = "role-id" # Replace with the actual role ID
  principal_object_id = azuread_application.app.object_id
  resource_object_id  = "resource-object-id" # Replace with the object ID of the resource (e.g., another app or service)
}

resource "azuread_application_api_access" "api_access" {
  application_object_id = azuread_application.app.object_id
  api_permission {
    id = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # Microsoft Graph - User.Read
    type = "Scope"
  }
}

resource "azuread_application_consent" "admin_consent" {
  application_object_id = azuread_application.app.object_id
  api_permission {
    id = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # Microsoft Graph - User.Read
    type = "Scope"
  }
}
