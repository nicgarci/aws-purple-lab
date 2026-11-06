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

resource "aws_cloudwatch_event_target" "purplelab-alerts" {
  rule = aws_cloudwatch_event_rule.purplelab-create-iam-user-rule.name
  arn = aws_cloudwatch_log_group.purplelab-alerts.arn
}