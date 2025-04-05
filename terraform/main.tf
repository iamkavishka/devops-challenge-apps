# Configure the remote backend
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstate<random>"  # Should replace with the storage account name
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

# Configure the Azure provider
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Validate resource names
locals {
  aca_env_name = lower(var.aca_env_name)
  webapp_name  = lower(var.webapp_name)
  api_name     = lower(var.api_name)
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

# Azure Container Registry (ACR)
resource "azurerm_container_registry" "acr" {
  name                = "${var.acr_name_prefix}${random_string.acr_suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = true
}

# Random string for ACR uniqueness
resource "random_string" "acr_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Azure Key Vault
resource "azurerm_key_vault" "main" {
  name                = var.key_vault_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    secret_permissions = ["Get", "Set", "List", "Delete"]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = "00000000-0000-0000-0000-000000000000" # Placeholder; update with ACA identity
    secret_permissions = ["Get"]
  }
}

# Data source for current Azure client config
data "azurerm_client_config" "current" {}

# Store PostgreSQL credentials in Key Vault
resource "azurerm_key_vault_secret" "pg_admin" {
  name         = "pg-admin"
  value        = var.postgres_admin_username
  key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_key_vault_secret" "pg_password" {
  name         = "pg-password"
  value        = var.postgres_admin_password
  key_vault_id = azurerm_key_vault.main.id
}

# Azure Database for PostgreSQL
resource "azurerm_postgresql_flexible_server" "postgres" {
  name                   = var.postgres_server_name
  location               = azurerm_resource_group.main.location
  resource_group_name    = azurerm_resource_group.main.name
  sku_name               = "B_Standard_B1ms"
  storage_mb             = 32768
  version                = "11"
  administrator_login    = azurerm_key_vault_secret.pg_admin.value
  administrator_password = azurerm_key_vault_secret.pg_password.value

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_postgresql_flexible_server_database" "db" {
  name      = var.postgres_db_name
  server_id = azurerm_postgresql_flexible_server.postgres.id
  collation = "en_US"

  lifecycle {
    prevent_destroy = true
  }
}

# Azure Container Apps Environment
resource "azurerm_container_app_environment" "main" {
  name                = local.aca_env_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Azure Container App for Web App
resource "azurerm_container_app" "webapp" {
  name                         = local.webapp_name
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"

  template {
    container {
      name   = "webapp"
      image  = "${azurerm_container_registry.acr.login_server}/webapp:latest"
      cpu    = 0.25
      memory = "0.5Gi"
      env {
        name  = "PORT"
        value = "3000"
      }
      env {
        name  = "API_HOST"
        value = "https://${azurerm_container_app.api.ingress[0].fqdn}"
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = 3000
    traffic_weight {
      percentage = 100
      latest_revision = true
    }
  }
}

# Azure Container App for API
resource "azurerm_container_app" "api" {
  name                         = local.api_name
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"

  template {
    container {
      name   = "api"
      image  = "${azurerm_container_registry.acr.login_server}/api:latest"
      cpu    = 0.25
      memory = "0.5Gi"
      env {
        name  = "PORT"
        value = "3000"
      }
      env {
        name  = "DB"
        value = "postgres://${azurerm_key_vault_secret.pg_admin.value}:${azurerm_key_vault_secret.pg_password.value}@${azurerm_postgresql_flexible_server.postgres.fqdn}:5432/${azurerm_postgresql_flexible_server_database.db.name}"
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = 3000
    traffic_weight {
      percentage = 100
      latest_revision = true
    }
  }

  depends_on = [azurerm_postgresql_flexible_server_database.db]
}

# Azure Monitor (Basic Monitoring)
resource "azurerm_monitor_action_group" "main" {
  name                = var.monitor_action_group_name
  resource_group_name = azurerm_resource_group.main.name
  short_name          = var.monitor_short_name
  enabled             = true

  email_receiver {
    name          = "admin"
    email_address = var.monitor_email
  }
}

resource "azurerm_monitor_metric_alert" "webapp_cpu" {
  name                = var.webapp_cpu_alert_name
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_container_app.webapp.id]
  description         = "Alert when Web App CPU exceeds 70%"
  enabled             = true

  criteria {
    metric_namespace = "microsoft.app/containerapps"
    metric_name      = "UsageNanoCores"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 700000000
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}

resource "azurerm_monitor_metric_alert" "api_cpu" {
  name                = var.api_cpu_alert_name
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_container_app.api.id]
  description         = "Alert when API CPU exceeds 70%"
  enabled             = true

  criteria {
    metric_namespace = "microsoft.app/containerapps"
    metric_name      = "UsageNanoCores"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 700000000
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}
