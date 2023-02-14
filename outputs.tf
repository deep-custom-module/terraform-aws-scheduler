output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}

output "state_table_id" {
  value       = join("", aws_dynamodb_table.state_table.*.id)
  description = "DynamoDB State table ID"
}

output "state_table_arn" {
  value       = join("", aws_dynamodb_table.state_table.*.arn)
  description = "DynamoDB State table ARN"
}
output "maintenance_table_id" {
  value       = join("", aws_dynamodb_table.maintenance_table.*.id)
  description = "DynamoDB maintenance table ID"
}

output "maintenance_table_arn" {
  value       = join("", aws_dynamodb_table.maintenance_table.*.arn)
  description = "DynamoDB maintenance table ARN"
}

output "config_table_id" {
  value       = join("", aws_dynamodb_table.config_table.*.id)
  description = "DynamoDB Config table ID"
}

output "config_table_arn" {
  value       = join("", aws_dynamodb_table.config_table.*.arn)
  description = "DynamoDB Config table ARN"
}