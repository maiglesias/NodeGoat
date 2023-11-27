module "dynamodb_tables" {
  source    = "../terraform/modules/dynamodb"
  pr_number = var.pr_number
  prod      = var.prod
}

module "KeenAppSync" {
  source = "../terraform/modules/appsync"

  pr_number                     = var.pr_number
  lambda_authorizer_name        = "pr-${var.pr_number}-LambdaAuthorizerServiceFunction"
  practices_dynamodb_table_arn  = module.dynamodb_tables.practices_dynamobd_table_arn
  practices_dynamodb_table_name = module.dynamodb_tables.practices_dynamobd_table_name
  nylas_http_endpoint           = var.nylas_http_endpoint
  depends_on                    = [module.dynamodb_tables]
}

module "sqs" {
  source    = "../terraform/modules/sqs"
  pr_number = var.pr_number
}
