output "resource-group-name" {
  value       = module.pr-env.resource-group-name
  description = "Azure Resource Group created name"
  sensitive   = false
}

output "log-workspace-name" {
  value       = module.pr-env.log-workspace-name
  description = "Log Analytics Workspace resource name"
  sensitive   = false
}

output "app-insights-name" {
  value       = module.pr-env.app-insights-name
  description = "Application Insights resource name"
  sensitive   = false
}

output "storage-account-name" {
  value       = module.pr-env.storage-account-name
  description = "Azure Storage account name"
  sensitive   = false
}

output "service-bus-namespace" {
  value       = module.pr-env.service-bus-namespace
  description = "Service bus namespace"
  sensitive   = false
}

output "cosmosdb-account-endpoint" {
  value       = module.pr-env.cosmosdb-account-endpoint
  description = "Cosmos Db account endpoint"
  sensitive   = false
}

output "redis-name" {
  value       = module.pr-env.redis-name
  description = "Redis resource name"
  sensitive   = false
}
