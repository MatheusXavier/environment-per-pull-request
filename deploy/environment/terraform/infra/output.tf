output "resource-group-name" {
  value       = azurerm_resource_group.rg.name
  description = "Azure Resource Group resource name"
  sensitive   = false
}

output "log-workspace-name" {
  value       = azurerm_log_analytics_workspace.log-workspace.name
  description = "Log Analytics Workspace resource name"
  sensitive   = false
}

output "app-insights-name" {
  value       = azurerm_application_insights.app-insights.name
  description = "Application Insights resource name"
  sensitive   = false
}

output "storage-account-name" {
  value       = azurerm_storage_account.storage.name
  description = "Azure Storage account name"
  sensitive   = false
}

output "service-bus-namespace" {
  value       = azurerm_servicebus_namespace.service-bus-namespace.name
  description = "Service bus namespace"
  sensitive   = false
}

output "cosmosdb-account-endpoint" {
  value       = azurerm_cosmosdb_account.cosmos-account.endpoint
  description = "Cosmos Db account endpoint"
  sensitive   = false
}

output "redis-name" {
  value       = azurerm_redis_cache.redis.name
  description = "Redis resource name"
  sensitive   = false
}
