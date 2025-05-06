variable "api_gateway_name" {
  description = "api gateway name"
  type        = string
}

variable "lambda_arn" {
  description = "The invoke ARN of the Lambda function to integrate."
  type        = string
}
variable "lambda_name" {
  description = "integrate Lambda function name"
  type        = string
}
variable "method" {
  type        = string
}


variable "parent_resource_id" {
  description = "parent resource id. If exist resource, this value is dummy"
  type        = string
  default = ""
}
variable "path_name" {
  description = "path name. If exist resource, this value is dummy"
  type        = string
  default = ""
}
variable "existing_resource_id" {
  description = "If exist resource, use this variable"
  type        = string
  default = ""
}
variable "request_parameters" {
  description = "e.g. {'method.request.path.accountId' = true}"
  type        = map(string)
  default = {}
}
