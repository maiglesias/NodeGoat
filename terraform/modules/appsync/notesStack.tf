//DATA SOURCE
resource "aws_appsync_datasource" "notes_datasource" {
  name       = var.notes_datasource_name
  api_id     = aws_appsync_graphql_api.AppSync.id
  type       = "NONE"
  depends_on = [aws_appsync_graphql_api.AppSync]
}

resource "aws_appsync_datasource" "notes_sub_datasource" {
  api_id     = aws_appsync_graphql_api.AppSync.id
  name       = var.notes_sub_datasource_name
  type       = "NONE"
  depends_on = [aws_appsync_graphql_api.AppSync]
}

//FUNCTIONS

resource "aws_appsync_function" "notes_create_note_function" {
  name                      = var.notes_create_note_function_name
  api_id                    = aws_appsync_graphql_api.AppSync.id
  data_source               = aws_appsync_datasource.notes_datasource.name
  function_version          = "2018-05-29"
  request_mapping_template  = "{\n    \"version\": \"2017-02-28\",\n    \"payload\": $util.toJson($context.args.input)\n}\n"
  response_mapping_template = "## Raise a GraphQL field error in case of a datasource invocation error\n#if($ctx.error)\n    $util.error($ctx.error.message, $ctx.error.type)\n#end\n## Pass back the result from DynamoDB. **\n$util.toJson($ctx.result)\n"
  depends_on                = [aws_appsync_datasource.notes_datasource]
}

resource "aws_appsync_function" "notes_update_note_function" {
  name                      = var.notes_update_note_function_name
  api_id                    = aws_appsync_graphql_api.AppSync.id
  data_source               = aws_appsync_datasource.notes_datasource.name
  function_version          = "2018-05-29"
  request_mapping_template  = "{\n    \"version\": \"2017-02-28\",\n    \"payload\": $util.toJson($context.args.input)\n}\n"
  response_mapping_template = "## Raise a GraphQL field error in case of a datasource invocation error\n#if($ctx.error)\n    $util.error($ctx.error.message, $ctx.error.type)\n#end\n## Pass back the result from DynamoDB. **\n$util.toJson($ctx.result)\n"
  depends_on                = [aws_appsync_datasource.notes_datasource]
}

//RESOLVERS

resource "aws_appsync_resolver" "notes_create_note_resolver" {
  api_id = aws_appsync_graphql_api.AppSync.id
  field  = var.notes_create_note_resolver_name
  type   = "Mutation"
  kind   = "PIPELINE"

  pipeline_config {
    functions = [aws_appsync_function.notes_create_note_function.function_id]
  }

  request_template  = "$util.toJson({\n\t\"practiceId\": $ctx.identity.resolverContext.practiceId\n})\n"
  response_template = "## Raise a GraphQL field error in case of a datasource invocation error\n#if($ctx.error)\n    $util.error($ctx.error.message, $ctx.error.type)\n#end\n## Pass back the result from DynamoDB. **\n$util.toJson($ctx.result)\n"
  depends_on        = [aws_appsync_function.notes_create_note_function]
}


resource "aws_appsync_resolver" "notes_update_note_resolver" {
  api_id = aws_appsync_graphql_api.AppSync.id
  field  = var.notes_update_note_resolver_name
  type   = "Mutation"
  kind   = "PIPELINE"

  pipeline_config {
    functions = [aws_appsync_function.notes_update_note_function.function_id]
  }

  request_template  = "$util.toJson({\n\t\"practiceId\": $ctx.identity.resolverContext.practiceId\n})\n"
  response_template = "## Raise a GraphQL field error in case of a datasource invocation error\n#if($ctx.error)\n    $util.error($ctx.error.message, $ctx.error.type)\n#end\n## Pass back the result from DynamoDB. **\n$util.toJson($ctx.result)\n"
  depends_on        = [aws_appsync_function.notes_update_note_function]
}

resource "aws_appsync_resolver" "notes_sub_create_note_resolver" {
  api_id            = aws_appsync_graphql_api.AppSync.id
  field             = var.notes_sub_create_note_resolver_name
  type              = "Subscription"
  data_source       = aws_appsync_datasource.notes_sub_datasource.name
  kind              = "UNIT"
  request_template  = "{\n    \"version\": \"2017-02-28\",\n    \"payload\": $util.toJson($context.args)\n}\n"
  response_template = "#if(! $ctx.identity.resolverContext.practiceId)\n\t$utils.unauthorized()\n#elseif($ctx.identity.resolverContext.practiceId != $ctx.arguments.practiceId)\n    $utils.unauthorized()\n#else\n##User is authorized, but we return null to continue\n    null\n#end\n"
  depends_on        = [aws_appsync_datasource.notes_sub_datasource]
}


resource "aws_appsync_resolver" "notes_sub_update_note_resolver" {
  api_id            = aws_appsync_graphql_api.AppSync.id
  field             = var.notes_sub_update_note_resolver_name
  type              = "Subscription"
  data_source       = aws_appsync_datasource.notes_sub_datasource.name
  kind              = "UNIT"
  request_template  = "{\n    \"version\": \"2017-02-28\",\n    \"payload\": $util.toJson($context.args)\n}\n"
  response_template = "#if(! $ctx.identity.resolverContext.practiceId)\n\t$utils.unauthorized()\n#elseif($ctx.identity.resolverContext.practiceId != $ctx.arguments.practiceId)\n    $utils.unauthorized()\n#else\n##User is authorized, but we return null to continue\n    null\n#end\n"
  depends_on        = [aws_appsync_datasource.notes_sub_datasource]
}
