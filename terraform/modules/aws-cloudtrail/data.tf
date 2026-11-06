data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "cloudtrail_s3_bucket_access_policy" {
  statement {
    sid = "AWSCloudTrailAclCheck"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.purplelab.arn]
    condition {
      test = "StringEquals"
      variable = "aws:SourceArn"
      values = ["arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:trail/purplelab-trail"]
    }
  }
  statement {
    sid = "AWSCloudTrailWrite"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.purplelab.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:trail/purplelab-trail"]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_s3_bucket_access_policy" {
  bucket = aws_s3_bucket.purplelab.id
  policy = data.aws_iam_policy_document.cloudtrail_s3_bucket_access_policy.json
}

data "aws_iam_policy_document" "cloudtrail_assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cloudtrail_cloudwatch_role" {
  name = "CloudTrailIAMRole"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_role.json
}

data "aws_iam_policy_document" "cloudtrail_cloudwatch_policy_doc" {
  statement {
    sid = "WriteCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:purplelab:*"]
  }
}

resource "aws_iam_policy" "cloudtrail_cloudwatch_policy" {
  name = "CloudTrailCloudWatchLogsPolicy"
  policy = data.aws_iam_policy_document.cloudtrail_cloudwatch_policy_doc.json
}

resource "aws_iam_policy_attachment" "cloudtrail_cloudwatch_attachment" {
  name = "CloudTrailCloudWatchLogsAttachment"
  policy_arn = aws_iam_policy.cloudtrail_cloudwatch_policy.arn
  roles = [aws_iam_role.cloudtrail_cloudwatch_role.name]
}