# Assignment 2: Linux VM Deployment with Nginx

This directory contains the Terraform configuration for Assignment 2, which deploys a Linux VM on Azure, sets up Nginx as a reverse proxy, and deploys a web app and API.

## Overview
- Resources Deployed:
  - Resource Group (`assignment2-rg`)
  - Virtual Network (VNet) and Subnet
  - Public IP Address
  - Network Interface (NIC)
  - Network Security Group (NSG) with rules for SSH and HTTP
  - Linux Virtual Machine (Ubuntu 20.04)
  - Azure Key Vault for storing the subscription ID
- Security:
  - Subscription ID is stored in Azure Key Vault.
  - SSH access is secured with a public key.
- Remote Backend: State is stored in Azure Blob Storage (`tfstate-rg`, `tfstateindunil`, `tfstate` container, `assignment2.tfstate` key).
- Scripts:
  - `setup.sh`: Installs Node.js, Nginx, and Certbot on the VM.
  - `deploy.sh`: Clones the app repository and deploys the web app and API.

## Prerequisites
- Azure CLI installed and logged in.
- Terraform installed.
- Storage account access key for the remote backend (set as `ARM_ACCESS_KEY`).
- SSH key pair for VM access.

## Setup Instructions
1. Navigate to the `assignment-2/` directory
