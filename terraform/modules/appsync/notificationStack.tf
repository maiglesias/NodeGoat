resource "aws_appsync_datasource" "notifications_datasource" {
  api_id     = aws_appsync_graphql_api.AppSync.id
  name       = var.notifications_datasource_name
  type       = "NONE"
  depends_on = [aws_appsync_graphql_api.AppSync]
}

resource "aws_appsync_function" "notifications_create_note_function" {
  api_id                    = aws_appsync_graphql_api.AppSync.id
  data_source               = aws_appsync_datasource.notifications_datasource.name
  name                      = var.notifications_create_note_function_name
  request_mapping_template  = "{\n    \"version\": \"2017-02-28\",\n    \"payload\": $util.toJson($context.args.input)\n}\n"
  response_mapping_template = "## Raise a GraphQL field error in case of a datasource invocation error\n#if($ctx.error)\n    $util.error($ctx.error.message, $ctx.error.type)\n#end\n## Pass back the result from DynamoDB. **\n$util.toJson($ctx.result)\n"
  depends_on                = [aws_appsync_datasource.notifications_datasource]
}

resource "aws_appsync_resolver" "notifications_create_note_resolver" {
  type              = "Mutation"
  api_id            = aws_appsync_graphql_api.AppSync.id
  field             = var.notifications_create_note_resolver_name
  request_template  = "$util.toJson({\n\t\"practiceId\": $ctx.identity.resolverContext.practiceId\n})\n"
  response_template = "## Raise a GraphQL field error in case of a datasource invocation error\n#if($ctx.error)\n    $util.error($ctx.error.message, $ctx.error.type)\n#end\n## Pass back the result from DynamoDB. **\n$util.toJson($ctx.result)\n"
  kind              = "PIPELINE"

  pipeline_config {
    functions = [
      aws_appsync_function.notifications_create_note_function.function_id
    ]
  }

  depends_on = [aws_appsync_function.notifications_create_note_function]
}

resource "aws_appsync_function" "notifications_update_note_function" {
  api_id                    = aws_appsync_graphql_api.AppSync.id
  data_source               = aws_appsync_datasource.notifications_datasource.name
  name                      = var.notifications_update_note_function_name
  request_mapping_template  = "{\n    \"version\": \"2017-02-28\",\n    \"payload\": $util.toJson($context.args.input)\n}\n"
  response_mapping_template = "## Raise a GraphQL field error in case of a datasource invocation error\n#if($ctx.error)\n    $util.error($ctx.error.message, $ctx.error.type)\n#end\n## Pass back the result from DynamoDB. **\n$util.toJson($ctx.result)\n"
  depends_on                = [aws_appsync_datasource.notifications_datasource]
}

resource "aws_appsync_resolver" "notifications_update_note_resolver" {
  type              = "Mutation"
  api_id            = aws_appsync_graphql_api.AppSync.id
  field             = var.notifications_update_note_resolver_name
  request_template  = "$util.toJson({\n\t\"practiceId\": $ctx.identity.resolverContext.practiceId\n})\n"
  response_template = "## Raise a GraphQL field error in case of a datasource invocation error\n#if($ctx.error)\n    $util.error($ctx.error.message, $ctx.error.type)\n#end\n## Pass back the result from DynamoDB. **\n$util.toJson($ctx.result)\n"
  kind              = "PIPELINE"

  pipeline_config {
    functions = [
      aws_appsync_function.notifications_update_note_function.function_id
    ]
  }

  depends_on = [aws_appsync_function.notifications_update_note_function]
}

resource "aws_appsync_datasource" "sub_practice_datasource" {
  api_id     = aws_appsync_graphql_api.AppSync.id
  name       = var.sub_practice_datasource_name
  type       = "NONE"
  depends_on = [aws_appsync_graphql_api.AppSync]
}

resource "aws_appsync_resolver" "sub_practice_create_note_resolver" {
  type              = "Subscription"
  api_id            = aws_appsync_graphql_api.AppSync.id
  data_source       = aws_appsync_datasource.sub_practice_datasource.name
  field             = var.sub_practice_create_note_resolver_name
  request_template  = "{\n    \"version\": \"2017-02-28\",\n    \"payload\": $util.toJson($context.args)\n}\n"
  response_template = "#if(! $ctx.identity.resolverContext.practiceId)\n\t$utils.unauthorized()\n#elseif($ctx.identity.resolverContext.practiceId != $ctx.arguments.practiceId)\n    $utils.unauthorized()\n#else\n##User is authorized, but we return null to continue\n    null\n#end\n"
  kind              = "UNIT"
  depends_on        = [aws_appsync_datasource.sub_practice_datasource]
}

resource "aws_appsync_resolver" "sub_practice_update_note_resolver" {
  type              = "Subscription"
  api_id            = aws_appsync_graphql_api.AppSync.id
  data_source       = aws_appsync_datasource.sub_practice_datasource.name
  field             = var.sub_practice_update_note_resolver_name
  request_template  = "{\n    \"version\": \"2017-02-28\",\n    \"payload\": $util.toJson($context.args)\n}\n"
  response_template = "#if(! $ctx.identity.resolverContext.practiceId)\n\t$utils.unauthorized()\n#elseif($ctx.identity.resolverContext.practiceId != $ctx.arguments.practiceId)\n    $utils.unauthorized()\n#else\n##User is authorized, but we return null to continue\n    null\n#end\n"
  kind              = "UNIT"
  depends_on        = [aws_appsync_datasource.sub_practice_datasource]
}
