# module "nylas_http_iam_role" {
#   source = "../iam"

#   role_name          = "pr-${var.pr_number}-${var.nylas_datasource_name}"
#   object_arn         = var.nylas_endpoint_arn
#   service_name       = var.nylas_service_name
#   set_of_permissions = var.nylas_endpoint_permissions
# }

// IAM ROLE

data "aws_iam_policy_document" "nylas_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["appsync.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "nylas_iam_role" {
  name               = "pr-${var.pr_number}-${var.nylas_datasource_name}_iam_role"
  assume_role_policy = data.aws_iam_policy_document.nylas_assume_role.json

  depends_on = [data.aws_iam_policy_document.nylas_assume_role]
}

//  DATA SOURCES

resource "aws_appsync_datasource" "nylas_datasource" {
  name   = var.nylas_datasource_name
  api_id = aws_appsync_graphql_api.AppSync.id
  type   = "HTTP"
  http_config {
    endpoint = var.nylas_http_endpoint
  }
  service_role_arn = aws_iam_role.nylas_iam_role.arn

  depends_on = [aws_iam_role.nylas_iam_role, aws_appsync_graphql_api.AppSync]
}

resource "aws_appsync_datasource" "calendar_sub_datasource" {
  name   = var.calendar_sub_datasource_name //sub_on_practice_id
  api_id = aws_appsync_graphql_api.AppSync.id
  type   = "NONE"

  depends_on = [aws_appsync_graphql_api.AppSync]
}

//functions

resource "aws_appsync_function" "nylas_get_event_function" {
  name             = var.nylas_get_event_function_name // get_events
  api_id           = aws_appsync_graphql_api.AppSync.id
  data_source      = aws_appsync_datasource.nylas_datasource.name
  function_version = "2018-05-29"

  request_mapping_template  = "{\n  \"method\": \"GET\",\n  \"resourcePath\": \"/events\",\n  \"params\": {\n    \"query\": $util.toJson($ctx.args.input),\n    \"headers\": {\n      \"Authorization\": \"Bearer $ctx.identity.resolverContext.nylasAccessToken\",\n      \"Cache-Control\": \"no-cache\"\n    }\n  }\n}\n"
  response_mapping_template = "## Raise a GraphQL field error in case of a datasource invocation error\n#if($ctx.error)\n  $util.error($ctx.error.message, $ctx.error.type)\n#end\n## If the response is not 200 then return an error. Else return the body **\n#if($ctx.result.statusCode == 200)\n  ## this is dumb, but necessary, and undocumented\n  #if( $velocityCount > 1 ) , #end\n  #set( $result = [] )\n  ## Loop through results\n  #foreach($entry in $util.parseJson($context.result.body))\n    ## parse all day out of the \"when\" time from nylas\n    #set( $isAllDay = 'false' )\n    #if( $entry.when.object == 'date')\n    #set($isAllDay = 'true')\n      #set($start = $entry.when.date)\n      #set($end = $entry.when.date)\n    #elseif($entry.when.object == 'datespan')\n    #set($isAllDay = 'true')\n      #set($start = $entry.when.start_date)\n      #set($end = $entry.when.end_date)\n    #else\n    #set($start = $entry.when.start_time)\n      #set($end = $entry.when.end_time)\n    #end\n\n    ## Add each item to the result array\n    $util.qr($result.add({\n      'eventId': $entry.id,\n      'start': $start,\n      'end': $end,\n      'description': $entry.description,\n      'provider': $entry.provider,\n      'recurrenceRule': $entry.recurrence.rrule,\n      'title': $entry.title,\n      'calendarId': $entry.calendar_id,\n      'isAllDay': $isAllDay,\n      'patientId': $entry.metadata.patientId,\n      'isAppointment': $entry.metadata.isAppointment,\n      'numParticipants': $entry.participants.size(),\n      'participantsString': $util.toJson($entry.participants),\n      'practiceId': $ctx.identity.resolverContext.practiceId,\n      'zoomUrl': $entry.metadata.zoomUrl,\n      'videoCall': $entry.conferencing\n    }))\n  #end\n  $util.toJson($result)\n#else\n  $utils.appendError($ctx.result.body, \"$ctx.result.statusCode\")\n#end\n"

  depends_on = [aws_appsync_datasource.nylas_datasource]
}


resource "aws_appsync_function" "nylas_update_event_function" {
  name                      = var.nylas_update_event_function_name //update_event
  api_id                    = aws_appsync_graphql_api.AppSync.id
  data_source               = aws_appsync_datasource.nylas_datasource.name
  function_version          = "2018-05-29"
  request_mapping_template  = "#if($util.isNullOrBlank($ctx.args.input.end) || $ctx.args.input.start == $ctx.args.input.end)\n  #set($when = {\"date\": $ctx.args.input.start})\n#elseif($util.isNullOrBlank($ctx.args.input.isAllDay) || !$util.isNullOrBlank($ctx.args.input.end) && $ctx.args.input.isAllDay == false)\n  #set($when = {\"start_time\": $ctx.args.input.start, \"end_time\": $ctx.args.input.end})\n#else\n  #set($when = {\"start_date\": $ctx.args.input.start, \"end_date\": $ctx.args.input.end})\n#end\n#set($gmail = \"gmail\")\n#if(!$util.isNullOrBlank($ctx.args.input.includeVideoCall) && $ctx.args.input.includeVideoCall && $util.isNullOrBlank($ctx.args.input.videoCall))\n  #set($conferencing = { \"provider\": \"#if($util.isNullOrBlank($ctx.identity.resolverContext.nylasProvider) || $ctx.identity.resolverContext.nylasProvider == $gmail)Google Meet#{else}Microsoft Teams#end\", \"autocreate\": {} })\n#else\n  #set($conferencing = $ctx.args.input.videoCall)\n#end\n\n#set($body = {\n  \"when\": $when,\n  \"description\": $ctx.args.input.description,\n  \"title\": $ctx.args.input.title,\n  \"calendar_id\": $ctx.args.input.calendarId,\n  \"metadata\": { \"patientId\": $ctx.args.input.patientId, \"isAppointment\": $ctx.args.input.isAppointment, \"zoomUrl\": $ctx.args.input.zoomUrl },\n  \"conferencing\": $conferencing\n})\n#if(!$util.isNullOrBlank($ctx.args.input.recurrenceRule))\n  $util.qr($body.put(\"recurrence\", { \"rrule\": [$ctx.args.input.recurrenceRule], \"timezone\": $ctx.args.input.timezone }))\n#end\n#set($myHeaders = {\n  \"Content-Type\": \"application/json\",\n  \"Authorization\": \"Bearer $ctx.identity.resolverContext.nylasAccessToken\"\n})\n#set($params = {\n  \"body\": $body,\n  \"headers\": $myHeaders\n})\n#set( $req = {\n\t\"method\": \"PUT\",\n  \"resourcePath\": \"/events/$ctx.args.input.eventId\",\n  \"params\": $params\n})\n\n$util.toJson($req)\n"
  response_mapping_template = "## Raise a GraphQL field error in case of a datasource invocation error\n#if($ctx.error)\n  $util.error($ctx.error.message, $ctx.error.type)\n#end\n## If the response is not 200 then return an error. Else return the body **\n#if($ctx.result.statusCode == 200)\n  #set($entry = $util.parseJson($context.result.body))\n  #set( $isAllDay = 'false' )\n  #if( $entry.when.object == 'date')\n    #set($isAllDay = 'true')\n    #set($start = $entry.when.date)\n    #set($end = $entry.when.date)\n  #elseif($entry.when.object == 'datespan')\n    #set($isAllDay = 'true')\n    #set($start = $entry.when.start_date)\n    #set($end = $entry.when.end_date)\n  #else\n    #set($start = $entry.when.start_time)\n    #set($end = $entry.when.end_time)\n  #end\n  $util.toJson({\n    'eventId': $entry.id,\n    'start': $start,\n    'end': $end,\n    'description': $entry.description,\n    'provider': $entry.provider,\n    'recurrenceRule': $entry.recurrence.rrule,\n    'title': $entry.title,\n    'calendarId': $entry.calendar_id,\n    'patientId': $entry.metadata.patientId,\n    'isAppointment': $entry.metadata.isAppointment,\n    'numParticipants': $entry.participants.size(),\n    'participantsString': $util.toJson($entry.participants),\n    'isAllDay': $isAllDay,\n    'practiceId': $ctx.identity.resolverContext.practiceId,\n    'zoomUrl': $entry.metadata.zoomUrl,\n    'videoCall': $entry.conferencing\n  })\n#else\n  $utils.appendError($ctx.result.body, \"$ctx.result.statusCode\")\n#end\n"
  depends_on                = [aws_appsync_datasource.nylas_datasource]
}

resource "aws_appsync_function" "nylas_create_event_function" {
  name                      = var.nylas_create_event_function_name //create_event
  api_id                    = aws_appsync_graphql_api.AppSync.id
  data_source               = aws_appsync_datasource.nylas_datasource.name
  function_version          = "2018-05-29"
  request_mapping_template  = "#if($util.isNullOrBlank($ctx.args.input.end) || $ctx.args.input.start == $ctx.args.input.end)\n  #set($when = {\"date\": $ctx.args.input.start})\n#elseif($util.isNullOrBlank($ctx.args.input.isAllDay) || !$util.isNullOrBlank($ctx.args.input.end) && $ctx.args.input.isAllDay == false)\n  #set($when = {\"start_time\": $ctx.args.input.start, \"end_time\": $ctx.args.input.end})\n#else\n  #set($when = {\"start_date\": $ctx.args.input.start, \"end_date\": $ctx.args.input.end})\n#end\n#set($body = {\n  \"when\": $when,\n  \"description\": $ctx.args.input.description,\n  \"title\": $ctx.args.input.title,\n  \"calendar_id\": $ctx.args.input.calendarId,\n  \"metadata\": { \"patientId\": $ctx.args.input.patientId, \"isAppointment\": $ctx.args.input.isAppointment, \"zoomUrl\": $ctx.args.input.zoomUrl }\n})\n#if(!$util.isNullOrBlank($ctx.args.input.recurrenceRule))\n  $util.qr($body.put(\"recurrence\", { \"rrule\": [$ctx.args.input.recurrenceRule], \"timezone\": $ctx.args.input.timezone }))\n#end\n#set($gmail = \"gmail\")\n#if(!$util.isNullOrBlank($ctx.args.input.includeVideoCall) && $ctx.args.input.includeVideoCall)\n  $util.qr($body.put(\"conferencing\", { \"provider\": \"#if($util.isNullOrBlank($ctx.identity.resolverContext.nylasProvider) || $ctx.identity.resolverContext.nylasProvider == $gmail)Google Meet#{else}Microsoft Teams#end\", \"autocreate\": {} }))\n#end\n#set($myHeaders = {\n  \"Content-Type\": \"application/json\",\n  \"Authorization\": \"Bearer $ctx.identity.resolverContext.nylasAccessToken\"\n})\n#set($params = {\n  \"body\": $body,\n  \"headers\": $myHeaders\n})\n#set( $req = {\n  \"method\": \"POST\",\n  \"resourcePath\": \"/events\",\n  \"params\": $params\n})\n\n$util.toJson($req)\n"
  response_mapping_template = "## Raise a GraphQL field error in case of a datasource invocation error\n#if($ctx.error)\n  $util.error($ctx.error.message, $ctx.error.type)\n#end\n## If the response is not 200 then return an error. Else return the body **\n#if($ctx.result.statusCode == 200)\n  #set($entry = $util.parseJson($context.result.body))\n  #set( $isAllDay = 'false' )\n  #if( $entry.when.object == 'date')\n    #set($isAllDay = 'true')\n    #set($start = $entry.when.date)\n    #set($end = $entry.when.date)\n  #elseif($entry.when.object == 'datespan')\n    #set($isAllDay = 'true')\n    #set($start = $entry.when.start_date)\n    #set($end = $entry.when.end_date)\n  #else\n    #set($start = $entry.when.start_time)\n    #set($end = $entry.when.end_time)\n  #end\n  $util.toJson({\n    'eventId': $entry.id,\n    'start': $start,\n    'end': $end,\n    'description': $entry.description,\n    'provider': $entry.provider,\n    'recurrenceRule': $entry.recurrence.rrule,\n    'title': $entry.title,\n    'calendarId': $entry.calendar_id,\n    'patientId': $entry.metadata.patientId,\n    'isAppointment': $entry.metadata.isAppointment,\n    'isAllDay': $isAllDay,\n    'numParticipants': $entry.participants.size(),\n    'participantsString': $util.toJson($entry.participants),\n    'zoomUrl': $entry.metadata.zoomUrl,\n    'practiceId': $ctx.identity.resolverContext.practiceId\n  })\n#else\n  $utils.appendError($ctx.result.body, \"$ctx.result.statusCode\")\n#end\n"
  depends_on                = [aws_appsync_datasource.nylas_datasource]
}

resource "aws_appsync_function" "nylas_delete_event_function" {
  name                      = var.nylas_delete_event_function_name //delete_event
  api_id                    = aws_appsync_graphql_api.AppSync.id
  data_source               = aws_appsync_datasource.nylas_datasource.name
  function_version          = "2018-05-29"
  request_mapping_template  = "{\n  \"method\": \"DELETE\",\n  \"resourcePath\": \"/events/$ctx.args.input.eventId\",\n  \"params\": {\n    \"headers\": {\n      \"Authorization\": \"Bearer $ctx.identity.resolverContext.nylasAccessToken\"\n    }\n  }\n}\n"
  response_mapping_template = "## Raise a GraphQL field error in case of a datasource invocation error\n#if($ctx.error)\n  $util.error($ctx.error.message, $ctx.error.type)\n#end\n#if($ctx.result.statusCode == 200)\n  {\n    \"eventId\": \"$ctx.args.input.eventId\",\n    \"calendarId\": \"$ctx.args.input.calendarId\",\n    \"practiceId\": \"$ctx.identity.resolverContext.practiceId\"\n  }\n#else\n    $utils.appendError($ctx.result.body, \"$ctx.result.statusCode\")\n#end\n"
  depends_on                = [aws_appsync_datasource.nylas_datasource]
}

//RESOLVERS 


resource "aws_appsync_resolver" "nylas_get_event_resolver" {
  api_id            = aws_appsync_graphql_api.AppSync.id
  field             = var.nylas_get_event_resolver_name
  type              = "Query"
  kind              = "PIPELINE"
  request_template  = "$util.toJson({\n\t\"practiceId\": $ctx.identity.resolverContext.practiceId\n})\n"
  response_template = "## Raise a GraphQL field error in case of a datasource invocation error\n#if($ctx.error)\n    $util.error($ctx.error.message, $ctx.error.type)\n#end\n## Pass back the result from DynamoDB. **\n$util.toJson($ctx.result)\n"

  pipeline_config {
    functions = [
      aws_appsync_function.nylas_get_event_function.function_id
    ]
  }

  depends_on = [aws_appsync_function.nylas_get_event_function]
}


resource "aws_appsync_resolver" "nylas_create_event_resolver" {
  api_id            = aws_appsync_graphql_api.AppSync.id
  field             = var.nylas_create_event_resolver_name //createEvent
  type              = "Mutation"
  kind              = "PIPELINE"
  request_template  = "$util.toJson({\n\t\"practiceId\": $ctx.identity.resolverContext.practiceId\n})\n"
  response_template = "## Raise a GraphQL field error in case of a datasource invocation error\n#if($ctx.error)\n    $util.error($ctx.error.message, $ctx.error.type)\n#end\n## Pass back the result from DynamoDB. **\n$util.toJson($ctx.result)\n"

  pipeline_config {
    functions = [
      aws_appsync_function.nylas_create_event_function.function_id
    ]
  }

  depends_on = [aws_appsync_function.nylas_create_event_function]
}


resource "aws_appsync_resolver" "nylas_update_event_resolver" {
  api_id            = aws_appsync_graphql_api.AppSync.id
  field             = var.nylas_update_event_resolver_name //updateEvent
  type              = "Mutation"
  kind              = "PIPELINE"
  request_template  = "$util.toJson({\n\t\"practiceId\": $ctx.identity.resolverContext.practiceId\n})\n"
  response_template = "## Raise a GraphQL field error in case of a datasource invocation error\n#if($ctx.error)\n    $util.error($ctx.error.message, $ctx.error.type)\n#end\n## Pass back the result from DynamoDB. **\n$util.toJson($ctx.result)\n"

  pipeline_config {
    functions = [
      aws_appsync_function.nylas_update_event_function.function_id
    ]
  }

  depends_on = [aws_appsync_function.nylas_update_event_function]
}


resource "aws_appsync_resolver" "nylas_delete_event_resolver" {
  api_id            = aws_appsync_graphql_api.AppSync.id
  field             = var.nylas_delete_event_resolver_name //deleteEvent
  type              = "Mutation"
  kind              = "PIPELINE"
  request_template  = "$util.toJson({\n\t\"practiceId\": $ctx.identity.resolverContext.practiceId\n})\n"
  response_template = "## Raise a GraphQL field error in case of a datasource invocation error\n#if($ctx.error)\n    $util.error($ctx.error.message, $ctx.error.type)\n#end\n## Pass back the result from DynamoDB. **\n$util.toJson($ctx.result)\n"

  pipeline_config {
    functions = [
      aws_appsync_function.nylas_delete_event_function.function_id
    ]
  }

  depends_on = [aws_appsync_function.nylas_delete_event_function]
}


resource "aws_appsync_resolver" "calendar_sub_oncreate_event_resolver" {
  api_id            = aws_appsync_graphql_api.AppSync.id
  type              = "Subscription"
  field             = var.calendar_sub_oncreate_event_resolver_name //onCreateEvent
  data_source       = aws_appsync_datasource.calendar_sub_datasource.name
  kind              = "UNIT"
  request_template  = "{\n    \"version\": \"2017-02-28\",\n    \"payload\": $util.toJson($context.args)\n}\n"
  response_template = "#if(! $ctx.identity.resolverContext.practiceId)\n\t$utils.unauthorized()\n#elseif($ctx.identity.resolverContext.practiceId != $ctx.arguments.practiceId)\n    $utils.unauthorized()\n#else\n##User is authorized, but we return null to continue\n    null\n#end\n"
  depends_on        = [aws_appsync_datasource.calendar_sub_datasource]
}

resource "aws_appsync_resolver" "calendar_sub_onupdate_event_resolver" {
  api_id            = aws_appsync_graphql_api.AppSync.id
  type              = "Subscription"
  field             = var.calendar_sub_onupdate_event_resolver_name // onUpdateEvent
  data_source       = aws_appsync_datasource.calendar_sub_datasource.name
  kind              = "UNIT"
  request_template  = "{\n    \"version\": \"2017-02-28\",\n    \"payload\": $util.toJson($context.args)\n}\n"
  response_template = "#if(! $ctx.identity.resolverContext.practiceId)\n\t$utils.unauthorized()\n#elseif($ctx.identity.resolverContext.practiceId != $ctx.arguments.practiceId)\n    $utils.unauthorized()\n#else\n##User is authorized, but we return null to continue\n    null\n#end\n"
  depends_on        = [aws_appsync_datasource.calendar_sub_datasource]
}

resource "aws_appsync_resolver" "calendar_sub_onudelete_event_resolver" {
  api_id            = aws_appsync_graphql_api.AppSync.id
  type              = "Subscription"
  field             = var.calendar_sub_onudelete_event_resolver_name // onDeleteEvent
  data_source       = aws_appsync_datasource.calendar_sub_datasource.name
  kind              = "UNIT"
  request_template  = "{\n    \"version\": \"2017-02-28\",\n    \"payload\": $util.toJson($context.args)\n}\n"
  response_template = "#if(! $ctx.identity.resolverContext.practiceId)\n\t$utils.unauthorized()\n#elseif($ctx.identity.resolverContext.practiceId != $ctx.arguments.practiceId)\n    $utils.unauthorized()\n#else\n##User is authorized, but we return null to continue\n    null\n#end\n"
  depends_on        = [aws_appsync_datasource.calendar_sub_datasource]
}
