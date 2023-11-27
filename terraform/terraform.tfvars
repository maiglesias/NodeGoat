# Config vars
aws_region = "us-east-1"

# Main / AppSync Module - KeenAppSync
#appsync_name              = "KeenAppSync" //added as default
#lambda_authorizer_name    = "pr-157-LambdaAuthorizerServiceFunction"
#appsync_apikey_expiration = "2023-08-02T12:34:56Z" #(DONE) investigar como pasar 1721491479 a RFC3339, investigar como en cdk lo calculan.
# practices_role_set_of_permissions = [
#   "dynamodb:BatchGetItem",
#   "dynamodb:GetRecords",
#   "dynamodb:GetShardIterator",
#   "dynamodb:Query",
#   "dynamodb:GetItem",
#   "dynamodb:Scan",
#   "dynamodb:ConditionCheckItem",
#   "dynamodb:BatchWriteItem",
#   "dynamodb:PutItem",
#   "dynamodb:UpdateItem",
#   "dynamodb:DeleteItem",
#   "dynamodb:DescribeTable"
# ]
#practices_datasource_name = "practices_db" //added as default

# Appsync Module - Notes Stack //all added to default
#notes_datasource_name               = "notes"
#notes_sub_datasource_name           = "sub_on_practice_id_notes"
# notes_create_note_function_name     = "create_note"
# notes_update_note_function_name     = "update_note"
# notes_create_note_resolver_name     = "createNote"
# notes_update_note_resolver_name     = "updateNote"
# notes_sub_create_note_resolver_name = "onCreateNote"
# notes_sub_update_note_resolver_name = "onUpdateNote"

# Appsync Module - Notification Stack //all added to default
# notifications_datasource_name           = "notifications"
# notifications_create_note_function_name = "create_notification"
# notifications_create_note_resolver_name = "createNotification"
# notifications_update_note_function_name = "update_notification"
# notifications_update_note_resolver_name = "updateNotification"
# sub_practice_datasource_name            = "sub_on_practice_id_notifications"
# sub_practice_create_note_resolver_name  = "onCreateNotification"
# sub_practice_update_note_resolver_name  = "onUpdateNotification"

# Appsync Module - Nylas Stack //almos all added to default
# nylas_datasource_name                      = "nylas"
nylas_http_endpoint = "https://api.nylas.com"
# calendar_sub_datasource_name               = "sub_on_practice_id"
# nylas_get_event_function_name              = "get_events"
# nylas_update_event_function_name           = "update_event"
# nylas_create_event_function_name           = "create_event"
# nylas_delete_event_function_name           = "delete_event"
# nylas_get_event_resolver_name              = "getEvents"
# nylas_create_event_resolver_name           = "createEvent"
# nylas_update_event_resolver_name           = "updateEvent"
# nylas_delete_event_resolver_name           = "deleteEvent"
# calendar_sub_oncreate_event_resolver_name  = "onCreateEvent"
# calendar_sub_onupdate_event_resolver_name  = "onUpdateEvent"
# calendar_sub_onudelete_event_resolver_name = "onDeleteEvent"

# KMS Module - Main
# aws_partition         = ""
# aws_account_id        = ""
# practices_kms_key_arn = ""

# SQS Module - Main
# scheduled_events_dlq_sqs_queue_name      = "scheduled_events_dlq"
# scheduled_events_dlq_sqs_queue_kms_key   = "" // Checkout that this is an output from the kms module
# scheduled_events_queue_sqs_queue_name    = "scheduled_events_queue"
# scheduled_events_queue_sqs_queue_kms_key = "" // Checkout that this is an output from the kms module
