# Tagging Module

This module defines standard tags for Azure resources.

## Inputs
- `project` (string): The project name (default: `wireapps`).
- `environment` (string): The environment (default: `dev`).

## Outputs
- `tags` (map(string)): The tags map to apply to resources.

## Usage
```hcl
module "tagging" {
  source      = "../modules/tagging"
  project     = "wireapps"
  environment = "dev"
}

resource "azurerm_resource_group" "main" {
  name     = "example-rg"
  location = "East US"
  tags     = module.tagging.tags
}
