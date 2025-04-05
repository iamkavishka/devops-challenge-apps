variable "project" {
  description = "The project name to include in tags"
  type        = string
  default     = "wireapps"
}

variable "environment" {
  description = "The environment (e.g., dev, prod) to include in tags"
  type        = string
  default     = "dev"
}

variable "custom_tags" {
  description = "Additional custom tags to apply to resources"
  type        = map(string)
  default     = {}
}
