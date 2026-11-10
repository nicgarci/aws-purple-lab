resource "aws_cloudwatch_event_rule" "purplelab-create-iam-user-rule" {
  name = "create-iam-user"
  description = "Detect \"CreateUser\" API Call."
  event_pattern = jsonencode({
    "detail-type": ["AWS API Call via CloudTrail"],
    "source": ["aws.iam"],
    "detail": {
      "eventName": ["CreateUser"]
    }
  })
}

resource "aws_cloudwatch_event_target" "purplelab_telegram_alerts" {
  rule = aws_cloudwatch_event_rule.purplelab-create-iam-user-rule.name
  arn = aws_lambda_function.telegram_alerter.arn
  role_arn = aws_iam_role.eventbridge_alerter_role.arn
}

resource "aws_cloudwatch_log_group" "purplelab_alerter_log_group" {
  name = "telegram_alerter"
  retention_in_days = 30
}