variable "pr_number" {
  type        = string
  default     = "test"
  description = "PR number"
}

variable "prod" {
  type        = bool
  default     = false
  description = "If set true deploy all resources, if false only pr's resources"
}
