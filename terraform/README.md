# Assignment 1: Azure Container Apps Deployment

This directory contains the Terraform configuration for Assignment 1, which deploys a web app and API using Azure Container Apps, backed by a PostgreSQL database.

- Resources Deployed:
  - Resource Group (wireapps-rg)
  - Azure Container Registry (ACR) for container images
  - Azure Key Vault for storing PostgreSQL credentials
  - Azure Database for PostgreSQL
  - Azure Container Apps Environment
  - Two Container Apps (web app and API)
  - Azure Monitor for basic monitoring (CPU alerts)
- Security:
  - PostgreSQL credentials are stored in Azure Key Vault.
  - Tagging module applies consistent tags to all resources.
- Remote Backend: State is stored in Azure Blob Storage.
  
## Lifecycle Block
- The `lifecycle` block with `prevent_destroy = true` is used for the PostgreSQL server and database to prevent accidental deletion.

## Prerequisites
- Azure CLI installed and logged in.
- Terraform installed.
- Storage account access key for the remote backend (set as `ARM_ACCESS_KEY`).

## Setup Instructions
1. Navigate to the `terraform/` directory
