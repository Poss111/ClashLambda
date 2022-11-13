resource "aws_cloudwatch_event_rule" "clash_bot_time_event_rule" {
  name                = "clash-bot-time-event"
  schedule_expression = "cron(0 11 ? * 2 *)"
  description         = "Event to trigger Clash Time Lambda Function."
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.clash_bot_time_event_rule.name
  target_id = "TriggerClashTimeLambda"
  arn       = aws_lambda_function.clash_bot_time_lambda.arn
}

resource "aws_sns_topic" "clash_bot_time_update_topic" {
  name = "clash-bot-time-update-topic"
}

resource "aws_sns_topic_subscription" "clash_bot_time_email_sub" {
  topic_arn = aws_sns_topic.clash_bot_time_update_topic.arn
  protocol  = "email"
  endpoint  = var.email_address
}

resource "aws_sns_topic_policy" "clash_bot_topic_policy" {
  arn = aws_sns_topic.clash_bot_time_update_topic.arn

  policy = data.aws_iam_policy_document.clash_bot_topic_policy_document.json
}

data "aws_iam_policy_document" "clash_bot_topic_policy_document" {
  policy_id = "__clash-bot-time-topic-policy"

  statement {
    sid = "__clash-bot-time-topic-policy-id"
    actions = var.topic_actions

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        data.aws_caller_identity.current.id,
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.clash_bot_time_update_topic.arn
    ]
  }
}