terraform {
  cloud {
    organization = "ClashBot"

    workspaces {
      name = "ClashBot-TimeLambda"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.21.0"
    }
  }
}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region

  default_tags {
    tags = {
      Application = "Clash-Bot-Webapp"
      Type        = "Lambda"
    }
  }
}

data "tfe_outputs" "clash-bot-discord-bot" {
  organization = "ClashBot"
  workspace    = "ClashBot"
}

data "aws_caller_identity" "current" {}

resource "aws_lambda_alias" "clash_bot_time_lambda_alias" {
  name             = "Clash_Bot_Time_Alias"
  description      = "A version of the Clash Bot Time Lambda."
  function_name    = aws_lambda_function.clash_bot_time_lambda.arn
  function_version = "$LATEST"
}

resource "aws_lambda_function_event_invoke_config" "clash_bot_func_event_config" {
  function_name          = aws_lambda_alias.clash_bot_time_lambda_alias.function_name
  maximum_retry_attempts = 2
}

resource "aws_lambda_function" "clash_bot_time_lambda" {
  depends_on    = [aws_iam_role_policy_attachment.cloudwatch-policy-attachment, aws_iam_policy.network_iam_policy]
  function_name = "clash-bot-time-function"
  role          = aws_iam_role.clash-bot-time-lambda-role.arn
  image_uri     = var.image_id
  package_type  = "Image"
  architectures = ["x86_64"]
  description   = "Used to retrieve upcoming League of Legends Clash Tournament times."

  timeout = 30

  vpc_config {
    security_group_ids = [aws_security_group.clash-bot-lambda-sg.id]
    subnet_ids         = data.tfe_outputs.clash-bot-discord-bot.values.private_subnet_ids
  }

  environment {
    variables = {
      snsTopicArn = aws_sns_topic.clash_bot_time_update_topic.arn
    }
  }
}
