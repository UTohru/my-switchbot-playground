terraform {
  backend "local" {
    path = "state-switch.prd.tfstate"
  }
}

locals {
  project_name = "switchbot-api"
  zip_filepath = "/functions/state-switch-lambda/deploy.zip"
}

data "terraform_remote_state" "iam" {
  backend = "local"
  config = {
    path = "../iam/iam.prd.tfstate"
  }
}


resource "aws_lambda_function" "switch_state_function" {
  function_name = format("%s-state-switch", local.project_name)
  role          = data.terraform_remote_state.iam.outputs.lambda_role_arn

  filename         = local.zip_filepath

  handler    = "dist/index.handler"
  runtime    = "nodejs22.x"
  timeout    = 90
  memory_size = 256
}

resource "aws_cloudwatch_log_group" "logs" {
  name              = "/aws/lambda/${aws_lambda_function.switch_state_function.function_name}"
  retention_in_days = 14
}



data "aws_api_gateway_rest_api" "api" {
  name = var.API_GATEWAY_NAME
}

# /devices part of /devices/{deviceId} 
resource "aws_api_gateway_resource" "devices" {
  rest_api_id = data.aws_api_gateway_rest_api.api.id
  parent_id   = data.aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "devices"
}

module "attach_apigateway" {
  source = "../../../modules/aws/api_lambda_endpoint"
  api_gateway_name = var.API_GATEWAY_NAME
  lambda_arn = aws_lambda_function.switch_state_function.invoke_arn
  lambda_name = aws_lambda_function.switch_state_function.function_name
  parent_resource_id = aws_api_gateway_resource.devices.id
  method = "GET"
  path_name = "{deviceId}"
  request_parameters = {
    "method.request.path.deviceId": true
    "method.request.querystring.action": true
  }
}
