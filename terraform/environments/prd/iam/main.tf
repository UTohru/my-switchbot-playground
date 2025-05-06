terraform {
  backend "local" {
    path = "iam.dev.tfstate"
  }
}

locals {
  project_name = "switchbot-api"
}

resource "aws_iam_role" "lambda_role" {
  name_prefix = "${local.project_name}-LambdaRole"
  # container application role
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Action    = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
      }
    ]
  })
}
resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect: "Allow",
        Action: [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ],
        Resource: var.dynamodb_arns
      },
      {
         Effect: "Allow",
         Action: [
             "ssm:DescribeParameters"
         ],
         Resource: "*"
      },
      {
        Effect: "Allow",
        Action: [
          "ssm:GetParameter*",
        ],
        Resource: "arn:aws:ssm:${var.AWS_DEFAULT_REGION}:${var.AWS_ACCOUNT_ID}:parameter/${local.project_name}*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
