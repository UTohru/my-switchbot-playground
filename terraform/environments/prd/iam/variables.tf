variable "AWS_ACCOUNT_ID" {
  type        = string
}

variable "AWS_DEFAULT_REGION" {
  type        = string
}

variable "dynamodb_arns" {
  type        = list(string)
}
