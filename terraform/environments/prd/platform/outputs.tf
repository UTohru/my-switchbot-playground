
output "dynamodb_arn" {
  value = aws_dynamodb_table.state_table.arn
}
