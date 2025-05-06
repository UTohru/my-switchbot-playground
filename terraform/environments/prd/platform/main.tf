terraform {
  backend "local" {
    path = "iam.dev.tfstate"
  }
}

locals {
  project_name = "switchbot-api"
}

resource "aws_dynamodb_table" "state_table" {
  name           = "SwitchState"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "DeviceId"

  attribute {
    name = "DeviceId"
    type = "S"
  }
}

resource "aws_api_gateway_rest_api" "api" {
  name = "switchbot-api"
}


resource "aws_ssm_parameter" "switchbot_token" {
  name  = format("/%s/bot-token", local.project_name)
  type  = "SecureString"
  value = var.SWITCHBOT_TOKEN
}

resource "aws_ssm_parameter" "switchbot_secret" {
  name  = format("/%s/bot-secret", local.project_name)
  type  = "SecureString"
  value = var.SWITCHBOT_SECRET
}


