data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "eventbridge_lambda_assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    condition {
      test = "StringEquals"
      variable = "aws:SourceArn"
      values = [ aws_cloudwatch_event_rule.purplelab-create-iam-user-rule.arn ]
    }
    condition {
      test = "StringEquals"
      variable = "aws:SourceAccount"
      values = [ data.aws_caller_identity.current.account_id ]
    }
  }
}

resource "aws_iam_role" "eventbridge_alerter_role" {
  name = "EventBridgeAlerterRole"
  assume_role_policy = data.aws_iam_policy_document.eventbridge_lambda_assume_role.json
}

data "aws_iam_policy_document" "invoke_lambda_alerter_document" {
  statement {
    effect = "Allow"
    actions = [ "lambda:InvokeFunction" ]
    resources = [ aws_lambda_function.telegram_alerter.arn ]
  }
}

resource "aws_iam_policy" "invoke_lambda_alerter_policy" {
  name = "InvokeTelegramAlerterPolicy"
  policy = data.aws_iam_policy_document.invoke_lambda_alerter_document.json
}

resource "aws_iam_role_policy_attachment" "eventbridge_alerter_attachment" {
  role = aws_iam_role.eventbridge_alerter_role.name
  policy_arn = aws_iam_policy.invoke_lambda_alerter_policy.arn
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    sid = "TrustEventBridgeService"
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    condition {
      test = "StringEquals"
      variable = "aws:SourceArn"
      values = [ aws_cloudwatch_event_rule.purplelab-create-iam-user-rule.arn ]
    }
    condition {
      test = "StringEquals"
      variable = "aws:SourceAccount"
      values = [ data.aws_caller_identity.current.account_id ]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "AlerterRole"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "lambda_execution_document" {
  statement {
    effect = "Allow"
    actions = [ "logs:CreateLogGroup" ]
    resources = [ "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:*" ]
  }
  statement {
    effect = "Allow"
    actions = [ 
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [ "${aws_cloudwatch_log_group.purplelab_alerter_log_group.arn}:*" ]
  }
}

resource "aws_iam_policy" "lambda_execution_policy" {
  name = "LambdaTelegramAlerter"
  policy = data.aws_iam_policy_document.lambda_execution_document.json
}

resource "aws_iam_role_policy_attachment" "name" {
  role = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_execution_policy.arn
}