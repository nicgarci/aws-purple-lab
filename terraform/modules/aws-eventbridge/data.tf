data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "eventbridge_cloudwatch_policy_doc" {
  statement {
    sid = "WriteEventBridgeAlerts"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch"
    ]
    resources = ["arn:${data.aws_partition.current.partition}:logs:us-east-1:${data.aws_caller_identity.current.account_id}:log-group:purplelab-alerts:*"]
    principals {
      identifiers = ["events.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_cloudwatch_log_resource_policy" "purplelab_eventbridge_alerts_policy" {
  policy_document = data.aws_iam_policy_document.eventbridge_cloudwatch_policy_doc.json
  policy_name = "purplelab_eventbridge_alerts_policy"
}