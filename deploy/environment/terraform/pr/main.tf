module "pr-env" {
  source = "../infra"

  location = "westeurope"
  resource_tags = {
    "environment" = "Stage"
  }
  environment_name           = var.environment_name
  sql_server_admin_login     = var.sql_server_admin_login
  sql_server_admin_password  = var.sql_server_admin_password
  key_vault_id               = var.key_vault_id
  sql_application_db_to_copy = "" # Here I fixed the resource id from the database that we are going to copy
  app_service_plan           = "" # I'm not creating an App Service Plan, we are using a existing one, so I fixed the resource id here
  certificate_thumbprint     = var.certificate_thumbprint
}
