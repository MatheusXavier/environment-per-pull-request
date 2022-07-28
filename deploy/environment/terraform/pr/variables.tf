# Environment name that we going to use, usually it's "pr<prNumber>"
variable "environment_name" {
  type        = string
  description = "Environment name that will be used to created the resources"
}

# I receive as paramter the sql server login to access the database later
variable "sql_server_admin_login" {
  type        = string
  description = "The administrator login name for the new server"
}

# I receive as parameter the sql server password to access the database later
variable "sql_server_admin_password" {
  type        = string
  description = "The password associated with the SQL Server admin login"
}

# We are storing the generated keys and connection string inside
# an existent Azure Key Vault resource, so we are receiving this id
# as parameter here
variable "key_vault_id" {
  type        = string
  description = "The Key Vault Id to store generated resources key."
}

# To add a custom host binding to the Web App it's necessary to
# add the certificate thumbprint, so we receive this value here
# as parameter
variable "certificate_thumbprint" {
  type        = string
  description = "certificate thumbprint"
}
