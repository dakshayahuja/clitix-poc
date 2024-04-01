variable "team_name" {
  description = "The name of the team"
  type        = string
}

variable "project_id" {
  description = "The GCP project ID"
  type        = string
  default     = "dakshay-goapptiv"
}

variable "health_check_link" {
  description = "Self-link of the global health check"
  type        = string
}