variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
  default     = "e6b1a91a-7af1-4025-8a99-f717210b4a91"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "wireapps-rg"
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "East US"
}

variable "acr_name_prefix" {
  description = "Prefix for the ACR name (random suffix added)"
  type        = string
  default     = "wireappsacr"
}

variable "key_vault_name" {
  description = "Name of the Key Vault"
  type        = string
  default     = "wireapps-kv"
}

variable "postgres_server_name" {
  description = "Name of the PostgreSQL server"
  type        = string
  default     = "wireapps-postgres"
}

variable "postgres_db_name" {
  description = "Name of the PostgreSQL database"
  type        = string
  default     = "appdb"
}

variable "postgres_admin_username" {
  description = "Admin username for PostgreSQL"
  type        = string
  default     = "pgadmin"
}

variable "postgres_admin_password" {
  description = "Admin password for PostgreSQL"
  type        = string
  default     = "SimplePassword123!"
  sensitive   = true
}

variable "aca_env_name" {
  description = "Name of the ACA environment"
  type        = string
  default     = "wireapps-aca-env"
}

variable "webapp_name" {
  description = "Name of the web app container"
  type        = string
  default     = "wireapps-webapp"
}

variable "api_name" {
  description = "Name of the API container"
  type        = string
  default     = "wireapps-api"
}

variable "monitor_action_group_name" {
  description = "Name of the monitor action group"
  type        = string
  default     = "wireapps-actiongroup"
}

variable "monitor_short_name" {
  description = "Short name for the monitor action group"
  type        = string
  default     = "wireapps-ag"
}

variable "monitor_email" {
  description = "Email address for monitoring alerts"
  type        = string
  default     = "indunilkawishka@gmail.com"
}

variable "webapp_cpu_alert_name" {
  description = "Name of the web app CPU alert"
  type        = string
  default     = "wireapps-webapp-cpu"
}

variable "api_cpu_alert_name" {
  description = "Name of the API CPU alert"
  type        = string
  default     = "wireapps-api-cpu"
}
