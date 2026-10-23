data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

resource "aws_cloudtrail" "purplelab" {
  depends_on = [ aws_s3_bucket_policy.cloudtrail_s3_bucket_access_policy ]
  name = "purplelab-trail"
  s3_bucket_name = aws_s3_bucket.purplelab.id
  is_multi_region_trail = true
  include_global_service_events = true
  enable_log_file_validation = true
}

resource "aws_s3_bucket" "purplelab" {
  bucket = format("purplelab-logs-%s-%s-an", data.aws_caller_identity.current.account_id, data.aws_region.current.region)
  bucket_namespace = "account-regional"
}

resource "aws_s3_bucket_lifecycle_configuration" "purplelab" {
  bucket = aws_s3_bucket.purplelab.bucket
  rule {
    id = "purplelab-retention-period"
    status = "Enabled"
    expiration {
      days = 90
    }
  }
}

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