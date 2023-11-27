resource "aws_sqs_queue" "scheduled_events_dlq_sqs_queue" {
  name                      = "pr-${var.pr_number}-${var.scheduled_events_dlq_sqs_queue_name}"
  kms_master_key_id         = var.sqs_kms_alias
  message_retention_seconds = 345600

}

resource "aws_sqs_queue" "scheduled_events_queue_sqs_queue" {
  name              = "pr-${var.pr_number}-${var.scheduled_events_queue_sqs_queue_name}"
  kms_master_key_id = var.sqs_kms_alias
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.scheduled_events_dlq_sqs_queue.arn
    maxReceiveCount     = 1
  })
}
