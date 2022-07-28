variable "environment_name" {
  type        = string
  description = "Environment name that will be used to created the resources."
}

variable "location" {
  type        = string
  description = "Location where resource will be created in Azure."
}

variable "resource_tags" {
  type        = map(string)
  description = "Resource tags that will be added on Azure Resources."
}

variable "sql_server_admin_login" {
  type        = string
  description = "The administrator login name for the new server."
}

variable "sql_server_admin_password" {
  type        = string
  description = "The password associated with the SQL Server admin login."
}

variable "key_vault_id" {
  type        = string
  description = "The Key Vault Id to store generated resources key."
}

variable "sql_application_db_to_copy" {
  type        = string
  description = "The SQL application db resource it to copy data."
}

variable "app_service_plan" {
  type        = string
  description = "The App Service Plan resource id."
}

variable "certificate_thumbprint" {
  type        = string
  description = "Certificate thumbprint"
}
