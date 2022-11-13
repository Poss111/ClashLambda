output "topic" {
  value       = aws_sns_topic.clash_bot_time_update_topic.id
  description = "The topic that is used by the lambda."
}

output "email_to_publish_to" {
  value       = aws_sns_topic_subscription.clash_bot_time_email_sub.endpoint
  description = "The email that is being published to."
}

output "lambda_alias" {
  value       = aws_lambda_alias.clash_bot_time_lambda_alias.function_version
  description = "The Lambda version published."
}