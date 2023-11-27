variable "aws_region" {
  type        = string
  description = "aws region"
}

variable "pr_number" {
  type        = string
  description = "PR number"
}

variable "prod" {
  type        = bool
  default     = false
  description = "If set true deploy all resources, if false only pr's resources"
}

# AppSync vars
// VARS FOR main.tf
variable "appsync_name" {
  type        = string
  default     = "KeenAppSync"
  description = "Name for the AppSync service"
}

# variable "appsync_domain" {
#   type        = string
#   default     = "dev.aerodpc.com"
#   description = "Route 53 domain name"
# }

# variable "appsync_certificate_arn" {
#   type        = string
# 

#variable "lambda_authorizer_name" {
#  type        = string
#  description = "Lambda authoraized arn for authentication"
#}

variable "authorizer_ttl" {
  type        = number
  default     = 600
  description = "Value for time to live for the lambda auth"
}

# variable "user_pool_id" {
#   type        = string
#   description = "User pool id from Cognito for auth"
# }

variable "appsync_apikey_expiration_days" {
  type        = number
  default     = 365
  description = "Expiration of AppSync Api Key in days"
}

variable "practices_datasource_name" {
  type        = string
  default     = "practices_db"
  description = "Name of practices datasource"
}

variable "practices_datasource_service_name" {
  type        = string
  default     = "appsync"
  description = "AWS service name"
}

variable "practices_role_set_of_permissions" {
  type = set(string)
  default = [
    "dynamodb:BatchGetItem",
    "dynamodb:GetRecords",
    "dynamodb:GetShardIterator",
    "dynamodb:Query",
    "dynamodb:GetItem",
    "dynamodb:Scan",
    "dynamodb:ConditionCheckItem",
    "dynamodb:BatchWriteItem",
    "dynamodb:PutItem",
    "dynamodb:UpdateItem",
    "dynamodb:DeleteItem",
    "dynamodb:DescribeTable"
  ]
  description = "Set of permissions for practices aim role"
}



// VARS FOR notesStack.tf (refactored)
variable "notes_datasource_name" {
  type        = string
  default     = "notes"
  description = "notesNone data source name"
}

variable "notes_sub_datasource_name" {
  type        = string
  default     = "sub_on_practice_id_notes"
  description = "notesNone sub data source name"
}

variable "notes_create_note_function_name" {
  type        = string
  default     = "create_note"
  description = "createNote function name"
}

variable "notes_update_note_function_name" {
  type        = string
  default     = "update_note"
  description = "updateNote function name"
}

variable "notes_create_note_resolver_name" {
  type        = string
  default     = "createNote"
  description = "MutationcreateNote resolver field name"
}

variable "notes_update_note_resolver_name" {
  type        = string
  default     = "updateNote"
  description = "MutationupdateNote resolver field name"
}

variable "notes_sub_create_note_resolver_name" {
  type        = string
  default     = "onCreateNote"
  description = "SubscriptiononCreateNote resolver field name"
}

variable "notes_sub_update_note_resolver_name" {
  type        = string
  default     = "onUpdateNote"
  description = "SubscriptiononUpdateNoteResolve resolver field"
}



// VARS FOR notificationStack.tf
variable "notifications_datasource_name" {
  type        = string
  default     = "notifications"
  description = "Name of notifications datasource"
}

variable "notifications_create_note_function_name" {
  type        = string
  default     = "create_notification"
  description = "Name of notifications create note function"
}

variable "notifications_create_note_resolver_name" {
  type        = string
  default     = "createNotification"
  description = "Name of notifications create note resolver"
}

variable "notifications_update_note_function_name" {
  type        = string
  default     = "update_notification"
  description = "Name of notifications update note function"
}

variable "notifications_update_note_resolver_name" {
  type        = string
  default     = "updateNotification"
  description = "Name of notifications update note resolver"
}

variable "sub_practice_datasource_name" {
  type        = string
  default     = "sub_on_practice_id_notifications"
  description = "Name of sub practices datasource"
}

variable "sub_practice_create_note_resolver_name" {
  type        = string
  default     = "onCreateNotification"
  description = "Name of sub practices create note resolver"
}

variable "sub_practice_update_note_resolver_name" {
  type        = string
  default     = "onUpdateNotification"
  description = "Name of nsub practices update note resolver"
}



// VARS FOR nylasStack.tf (to be refactored)
variable "nylas_datasource_name" {
  type        = string
  default     = "nylas"
  description = "Name of Nylas datasource"
}

# variable "nylas_endpoint_arn" {
#   type        = string
#   description = "ARN of Nylas endpoint"
# }

# variable "nylas_service_name" {
#   type        = string
#   default     = "appsync"
#   description = "AWS service name"
# }

# variable "nylas_endpoint_permissions" {
#   type        = set(string)
#   description = "Set of permissions for nylas iam role"
# }

variable "nylas_http_endpoint" {
  type        = string
  description = "Endpoint of Nylas HTTP"
}

variable "calendar_sub_datasource_name" {
  type        = string
  default     = "sub_on_practice_id"
  description = "Name of CalendarSubscriptionNoneDataSource"
}

variable "nylas_get_event_function_name" {
  type        = string
  default     = "get_events"
  description = "Name of getEventsFunction"
}

variable "nylas_update_event_function_name" {
  type        = string
  default     = "update_event"
  description = "Name of updateEventFunction"
}

variable "nylas_create_event_function_name" {
  type        = string
  default     = "create_event"
  description = "Name of createEventFunction"
}

variable "nylas_delete_event_function_name" {
  type        = string
  default     = "delete_event"
  description = "Name of deleteEventFunction"
}

variable "nylas_get_event_resolver_name" {
  type        = string
  default     = "getEvents"
  description = "Name of get event resolver"
}

variable "nylas_create_event_resolver_name" {
  type        = string
  default     = "createEvent"
  description = "Name of create event resolver"
}

variable "nylas_update_event_resolver_name" {
  type        = string
  default     = "updateEvent"
  description = "Name of update event resolver"
}

variable "nylas_delete_event_resolver_name" {
  type        = string
  default     = "deleteEvent"
  description = "Name of delete event resolver"
}

variable "calendar_sub_oncreate_event_resolver_name" {
  type        = string
  default     = "onCreateEvent"
  description = "Calendar sub oncreate event name"
}

variable "calendar_sub_onupdate_event_resolver_name" {
  type        = string
  default     = "onUpdateEvent"
  description = "Calendar sub onupdate event name"
}

variable "calendar_sub_onudelete_event_resolver_name" {
  type        = string
  default     = "onDeleteEvent"
  description = "Calendar sub ondelete event name"
}
