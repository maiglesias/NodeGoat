output "sqs_queue_url" {
  value = aws_sqs_queue.scheduled_events_queue_sqs_queue.url
}
