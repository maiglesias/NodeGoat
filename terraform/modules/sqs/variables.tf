variable "scheduled_events_dlq_sqs_queue_name" {
  type        = string
  default = "ScheduledEventsServiceStack-DLQ"
  description = "Scheduled Evenets DLQ name"
}

variable "pr_number" {
  type        = string
  default     = "test"
  description = "PR number"
}

variable "sqs_kms_alias" {
  type        = string
  default     = "alias/aws/sqs"
  description = "Sqs KMS Key Alias"
}

variable "scheduled_events_queue_sqs_queue_name" {
  type        = string
  default = "ScheduledEventsServiceStack-Queue"
  description = "Scheduled Evenets Queue name"
}
