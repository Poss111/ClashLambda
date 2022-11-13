resource "aws_iam_policy" "cloudwatch_iam_policy" {
  name = "clash-bot-time-cloudwatch-lambda-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = var.cloudwatch_iam_policies,
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_policy" "network_iam_policy" {
  name = "clash-bot-time-network-lambda-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = var.network_iam_policies,
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_policy" "cloudwatch_secret_policy" {
  name = "clash-bot-time-secret-lambda-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = var.secret_iam_policies,
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_policy" "sns_policy" {
  name = "clash-bot-time-sns-lambda-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = var.sns_policies,
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_lambda_permission" "log_event_trigger_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.clash_bot_time_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.clash_bot_time_event_rule.arn
}

resource "aws_iam_role" "clash-bot-time-lambda-role" {
  name = "clash-bot-time-lambda-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch-policy-attachment" {
  role       = aws_iam_role.clash-bot-time-lambda-role.name
  policy_arn = aws_iam_policy.cloudwatch_iam_policy.arn
}

resource "aws_iam_role_policy_attachment" "network-policy-attachment" {
  role       = aws_iam_role.clash-bot-time-lambda-role.name
  policy_arn = aws_iam_policy.network_iam_policy.arn
}

resource "aws_iam_role_policy_attachment" "secret-policy-attachment" {
  role       = aws_iam_role.clash-bot-time-lambda-role.name
  policy_arn = aws_iam_policy.cloudwatch_secret_policy.arn
}

resource "aws_iam_role_policy_attachment" "sns-policy-attachment" {
  role       = aws_iam_role.clash-bot-time-lambda-role.name
  policy_arn = aws_iam_policy.sns_policy.arn
}

