output "APPSYNC_NOTES_API_URL" {
  value = module.KeenAppSync.appsync_graphql_api_endpoint["GRAPHQL"]
}

output "SQS_QUEUE_URL" {
  value = module.sqs.sqs_queue_url
}
