# Creating resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.environment_name}-ResourceGroup"
  location = var.location
  tags     = var.resource_tags
}

# Creating log workspace to use in Application Insights resource
resource "azurerm_log_analytics_workspace" "log-workspace" {
  name                = "${var.environment_name}-log-workspace"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.resource_tags
}

# Creating application insights
resource "azurerm_application_insights" "app-insights" {
  name                = "${var.environment_name}-appinsights"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  workspace_id        = azurerm_log_analytics_workspace.log-workspace.id
  application_type    = "web"
  tags                = var.resource_tags
}

# Creating Azure Storage Account
resource "azurerm_storage_account" "storage" {
  name                     = "${var.environment_name}storage"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Hot"
  tags                     = var.resource_tags
}

# Creating Azure Service Bus namespace
resource "azurerm_servicebus_namespace" "service-bus-namespace" {
  name                = "${var.environment_name}-bus"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Basic"
  tags                = var.resource_tags
}

# Creating a queue inside the Azure Service Bus
resource "azurerm_servicebus_queue" "application-queue" {
  name                = "application-events"
  namespace_id        = azurerm_servicebus_namespace.service-bus-namespace.id
  enable_partitioning = true
}

# Creating a Cosmos Db Account
resource "azurerm_cosmosdb_account" "cosmos-account" {
  name                = "${var.environment_name}-cosmosaccount"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  offer_type          = "Standard"
  tags                = var.resource_tags

  capabilities {
    name = "EnableServerless"
  }

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.rg.location
    failover_priority = 0
  }
}

# Creating Cosmos Db database
resource "azurerm_cosmosdb_sql_database" "cosmos-sql-db" {
  name                = "StageDb"
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.cosmos-account.name
}

# Creating a container inside the Cosmos Db database
resource "azurerm_cosmosdb_sql_container" "cosmos-container-sample" {
  name                = "ContainerSample"
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.cosmos-account.name
  database_name       = azurerm_cosmosdb_sql_database.cosmos-sql-db.name
  partition_key_path  = "/partition"
}

# Creating a Azure Redis Cache
resource "azurerm_redis_cache" "redis" {
  name                = "${var.environment_name}-redis-cache"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku_name            = "Basic"
  family              = "C"
  capacity            = 0
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"
  tags                = var.resource_tags
}

# Creating MS SQL server
resource "azurerm_mssql_server" "sql-server" {
  name                         = "${var.environment_name}-sql-server"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sql_server_admin_login
  administrator_login_password = var.sql_server_admin_password
  minimum_tls_version          = "1.2"
  tags                         = var.resource_tags
}

# Adding firewall rule indicating that Azure Services can access this server
resource "azurerm_mssql_firewall_rule" "sql-server-allow-azure-access" {
  name             = "AllowAccessToAzureServices"
  server_id        = azurerm_mssql_server.sql-server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Creating a SQL database inside SQL Server
resource "azurerm_mssql_database" "application-db-one" {
  name        = "${var.environment_name}-application-db-one"
  server_id   = azurerm_mssql_server.sql-server.id
  collation   = "SQL_Latin1_General_CP1_CI_AS"
  sku_name    = "Basic"
  max_size_gb = 2
  tags        = var.resource_tags
}

# Creating another SQL database inside SQL Server
resource "azurerm_mssql_database" "application-db-two" {
  name                        = "${var.environment_name}-application-db-two"
  server_id                   = azurerm_mssql_server.sql-server.id
  collation                   = "SQL_Latin1_General_CP1_CI_AS"
  sku_name                    = "Basic"
  max_size_gb                 = 2
  create_mode                 = "Copy"
  creation_source_database_id = var.sql_application_db_to_copy
  tags                        = var.resource_tags
}

# Creating a web app inside existing App Service Plan
resource "azurerm_windows_web_app" "frontend-web-app" {
  name                = "${var.environment_name}-frontend"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = var.app_service_plan
  tags                = var.resource_tags
  https_only          = true

  site_config {
    http2_enabled      = true
    use_32_bit_worker  = false
    websockets_enabled = true
  }

  app_settings = {
    "WEBSITE_NODE_DEFAULT_VERSION" = "8.11.2"
  }
}

# Creating a custom host binding for this web app
resource "azurerm_app_service_custom_hostname_binding" "web-app-client-host-binding" {
  hostname            = "${var.environment_name}.something.io"
  app_service_name    = azurerm_windows_web_app.frontend-web-app.name
  resource_group_name = azurerm_resource_group.rg.name
  ssl_state           = "SniEnabled"
  thumbprint          = var.certificate_thumbprint
}

# Saving database ONE connection string to existent Azure Key Vault
resource "azurerm_key_vault_secret" "application-db-one-connection-string-secret" {
  name         = "${var.environment_name}-applicationSqlDbOne"
  value        = "Server=tcp:${azurerm_mssql_server.sql-server.name}.database.windows.net,1433;Initial Catalog=${azurerm_mssql_database.application-db-one.name};Persist Security Info=False;User ID=${var.sql_server_admin_login};Password=${var.sql_server_admin_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  key_vault_id = var.key_vault_id
}

# Saving database TWO connection string to existent Azure Key Vault
resource "azurerm_key_vault_secret" "application-db-two-connection-string-secret" {
  name         = "${var.environment_name}-applicationSqlDbTwo"
  value        = "Server=tcp:${azurerm_mssql_server.sql-server.name}.database.windows.net,1433;Initial Catalog=${azurerm_mssql_database.application-db-two.name};Persist Security Info=False;User ID=${var.sql_server_admin_login};Password=${var.sql_server_admin_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  key_vault_id = var.key_vault_id
}

# Saving app insights instrumentation key to existent Azure Key Vault
resource "azurerm_key_vault_secret" "app-insights-instrumentation-key-secret" {
  name         = "${var.environment_name}-appInsights"
  value        = azurerm_application_insights.app-insights.instrumentation_key
  key_vault_id = var.key_vault_id
}

# Saving Azure Redis Cache connection string to existent Azure Key Vault
resource "azurerm_key_vault_secret" "redis-connection-string-secret" {
  name         = "${var.environment_name}-redis"
  value        = azurerm_redis_cache.redis.primary_connection_string
  key_vault_id = var.key_vault_id
}

# Saving Azure Storage connection string to existent Azure Key Vault
resource "azurerm_key_vault_secret" "application-storage-connection-string-secret" {
  name         = "${var.environment_name}-applicationAzureStorage"
  value        = azurerm_storage_account.storage.primary_connection_string
  key_vault_id = var.key_vault_id
}

# Saving Azure Service Bus endpoint to existent Azure Key Vault 
resource "azurerm_key_vault_secret" "service-bus-endpoint-secret" {
  name         = "${var.environment_name}-serviceBusEndpoint"
  value        = "sb://${azurerm_servicebus_namespace.service-bus-namespace.name}.servicebus.windows.net/"
  key_vault_id = var.key_vault_id
}

# Saving Azure Service Bus access key name to existent Azure Key Vault
resource "azurerm_key_vault_secret" "service-bus-access-key-name-secret" {
  name         = "${var.environment_name}-serviceBusAccessKeyName"
  value        = "RootManageSharedAccessKey"
  key_vault_id = var.key_vault_id
}

# Saving Azure Service Bus primary key to existent Azure Key Vault
resource "azurerm_key_vault_secret" "service-bus-access-key-secret" {
  name         = "${var.environment_name}-serviceBusAccessKey"
  value        = azurerm_servicebus_namespace.service-bus-namespace.default_primary_key
  key_vault_id = var.key_vault_id
}

# Saving cosmos db endpoint to existent Azure Key Vault
resource "azurerm_key_vault_secret" "cosmos-db-endpoint-secret" {
  name         = "${var.environment_name}-cosmosDbEndpoint"
  value        = azurerm_cosmosdb_account.cosmos-account.endpoint
  key_vault_id = var.key_vault_id
}

# Saving cosmos db key to existent Azure Key Vault
resource "azurerm_key_vault_secret" "cosmos-db-key-secret" {
  name         = "${var.environment_name}-cosmosDbKey"
  value        = azurerm_cosmosdb_account.cosmos-account.primary_key
  key_vault_id = var.key_vault_id
}
