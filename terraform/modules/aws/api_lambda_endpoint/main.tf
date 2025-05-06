data "aws_api_gateway_rest_api" "api" {
  name = var.api_gateway_name
}

resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${data.aws_api_gateway_rest_api.api.execution_arn}/*/${var.method}/*"
}


# If existing_resource_id is not input, create it.
resource "aws_api_gateway_resource" "new_resource" {
  count = var.existing_resource_id == "" ? 1 : 0

  rest_api_id = data.aws_api_gateway_rest_api.api.id
  parent_id   = var.parent_resource_id
  path_part   = var.path_name
}
locals {
  resource_id = var.existing_resource_id == "" ? aws_api_gateway_resource.new_resource[0].id : var.existing_resource_id
}

resource "aws_api_gateway_method" "new_method" {
  rest_api_id      = data.aws_api_gateway_rest_api.api.id
  resource_id      = local.resource_id
  http_method      = var.method
  authorization    = "NONE"
  api_key_required = true

  request_parameters = var.request_parameters
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = data.aws_api_gateway_rest_api.api.id
  resource_id             = local.resource_id
  http_method             = var.method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_arn
}
