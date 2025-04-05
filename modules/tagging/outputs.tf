output "tags" {
  description = "The tags to apply to resources"
  value = {
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
  }
}
