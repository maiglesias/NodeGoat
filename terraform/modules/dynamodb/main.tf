resource "aws_dynamodb_table" "practices" {
  name         = "pr-${var.pr_number}-Practices"
  hash_key     = "practiceId"
  range_key    = "sk"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "practiceId"
    type = "S"
  }
  attribute {
    name = "sk"
    type = "S"
  }
  attribute {
    name = "recordType"
    type = "S"
  }
  attribute {
    name = "nylasAccountId"
    type = "S"
  }

  global_secondary_index {
    name            = "PracticeRecordTypeIndex"
    hash_key        = "practiceId"
    range_key       = "recordType"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "PracticeNylasAccountIndex"
    hash_key        = "nylasAccountId"
    range_key       = "practiceId"
    projection_type = "ALL"
  }
}

resource "aws_dynamodb_table" "billing" {
  count        = var.prod ? 1 : 0 #Only creates the table if prod is set to true
  name         = "pr-${var.pr_number}-Billings"
  hash_key     = "practiceId"
  range_key    = "sk"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "practiceId"
    type = "S"
  }
  attribute {
    name = "sk"
    type = "S"
  }
  attribute {
    name = "subscriptionId"
    type = "S"
  }
  attribute {
    name = "recordType"
    type = "S"
  }

  global_secondary_index {
    name            = "BillingRecordTypeIndex"
    hash_key        = "practiceId"
    range_key       = "recordType"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "SubscriptionIdIndex"
    hash_key        = "practiceId"
    range_key       = "subscriptionId"
    projection_type = "ALL"
  }
} # 2 GSI

resource "aws_dynamodb_table" "companies" {
  count        = var.prod ? 1 : 0 #Only creates the table if prod is set to true
  name         = "pr-${var.pr_number}-Companies"
  hash_key     = "practiceId"
  range_key    = "sk"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "practiceId"
    type = "S"
  }
  attribute {
    name = "sk"
    type = "S"
  }

  attribute {
    name = "recordType"
    type = "S"
  }

  global_secondary_index {
    name            = "CompanyRecordTypeIndex"
    hash_key        = "practiceId"
    range_key       = "recordType"
    projection_type = "ALL"
  }

} # 1 GSI

resource "aws_dynamodb_table" "files" {
  name         = "pr-${var.pr_number}-Files"
  hash_key     = "practiceId"
  range_key    = "sk"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "practiceId"
    type = "S"
  }
  attribute {
    name = "sk"
    type = "S"
  }

} # none GSI

resource "aws_dynamodb_table" "inventory" {
  name         = "pr-${var.pr_number}-Inventories"
  hash_key     = "practiceId"
  range_key    = "sk"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "practiceId"
    type = "S"
  }
  attribute {
    name = "sk"
    type = "S"
  }

} # none GSI

resource "aws_dynamodb_table" "logger" {
  count        = var.prod ? 1 : 0 #Only creates the table if prod is set to true
  name         = "pr-${var.pr_number}-Logger"
  hash_key     = "practiceId"
  range_key    = "sk"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "practiceId"
    type = "S"
  }
  attribute {
    name = "sk"
    type = "S"
  }

} # none GSI

resource "aws_dynamodb_table" "logins" {
  count        = var.prod ? 1 : 0 #Only creates the table if prod is set to true
  name         = "pr-${var.pr_number}-Logins"
  hash_key     = "username"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "username"
    type = "S"
  }

} # none GSI

resource "aws_dynamodb_table" "notes" {
  name         = "pr-${var.pr_number}-Notes"
  hash_key     = "practiceId"
  range_key    = "sk"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "practiceId"
    type = "S"
  }
  attribute {
    name = "sk"
    type = "S"
  }
  attribute {
    name = "patientIdEventTimestamp"
    type = "S"
  }
  attribute {
    name = "patientIdNoteTypeStatusTimestamp"
    type = "S"
  }

  local_secondary_index {
    name = "PatientIdEventTimestampNoteTypeIndex"
    #hash_key           = "practiceId"
    range_key       = "patientIdEventTimestamp"
    projection_type = "ALL"
  }

  local_secondary_index {
    name = "PatientIdNoteTypeStatusTimestampIndex"
    #hash_key           = "practiceId"
    range_key       = "patientIdNoteTypeStatusTimestamp"
    projection_type = "ALL"
  }


} # 2 LSI

resource "aws_dynamodb_table" "patients" {
  name         = "pr-${var.pr_number}-Patients"
  hash_key     = "practiceId"
  range_key    = "sk"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "practiceId"
    type = "S"
  }
  attribute {
    name = "sk"
    type = "S"
  }
  attribute {
    name = "email"
    type = "S"
  }
  attribute {
    name = "recordType"
    type = "S"
  }
  attribute {
    name = "primaryPhoneNumber"
    type = "S"
  }
  attribute {
    name = "payingPatientId"
    type = "S"
  }

  global_secondary_index {
    name            = "PatientEmailIndex"
    hash_key        = "practiceId"
    range_key       = "email"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "PatientPhoneNumberIndex"
    hash_key        = "practiceId"
    range_key       = "primaryPhoneNumber"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "PatientRecordTypeIndex"
    hash_key        = "practiceId"
    range_key       = "recordType"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "PayingPatientIdIndex"
    hash_key        = "practiceId"
    range_key       = "payingPatientId"
    projection_type = "ALL"
  }
} # 4 GSI

resource "aws_dynamodb_table" "patients-external" {
  count        = var.prod ? 1 : 0 #Only creates the table if prod is set to true
  name         = "pr-${var.pr_number}-PatientsExternal"
  hash_key     = "practiceId"
  range_key    = "sk"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "practiceId"
    type = "S"
  }
  attribute {
    name = "sk"
    type = "S"
  }
} # none GSI

resource "aws_dynamodb_table" "Reminders" {
  name         = "pr-${var.pr_number}-Reminders"
  hash_key     = "practiceId"
  range_key    = "sk"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "practiceId"
    type = "S"
  }
  attribute {
    name = "sk"
    type = "S"
  }
  attribute {
    name = "notificationTypeAssignedStatus"
    type = "S"
  }
  attribute {
    name = "notificationTypeAuthorStatus"
    type = "S"
  }
  attribute {
    name = "relatedToStatus"
    type = "S"
  }

  global_secondary_index {
    name            = "NotificationTypeAssignedToStatusIndex"
    hash_key        = "practiceId"
    range_key       = "notificationTypeAssignedStatus"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "NotificationTypeAuthorToStatusIndex"
    hash_key        = "practiceId"
    range_key       = "notificationTypeAuthorStatus"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "RelatedToStatusIndex"
    hash_key        = "practiceId"
    range_key       = "relatedToStatus"
    projection_type = "ALL"
  }
} # 3 GSI

resource "aws_dynamodb_table" "ScheduledEvents" {
  name         = "pr-${var.pr_number}-ScheduledEvents"
  hash_key     = "practiceId"
  range_key    = "sk"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "practiceId"
    type = "S"
  }
  attribute {
    name = "sk"
    type = "S"
  }

  attribute {
    name = "when"
    type = "S"
  }

  attribute {
    name = "status"
    type = "S"
  }

  global_secondary_index {
    name            = "StatusWhenIndex"
    hash_key        = "status"
    range_key       = "when"
    projection_type = "ALL"
  }

} # 1 GSI
