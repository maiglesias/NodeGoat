data "aws_lambda_function" "authorizer_lambda" {
  function_name = var.lambda_authorizer_name
}