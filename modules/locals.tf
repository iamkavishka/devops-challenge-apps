locals {
  # Standard tags
  standard_tags = {
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
  }

  # Combine standard tags with custom tags
  final_tags = merge(local.standard_tags, var.custom_tags)
}
