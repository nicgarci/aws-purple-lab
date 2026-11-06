resource "aws_s3_bucket" "purplelab" {
  bucket = format("purplelab-logs-%s-%s-an", data.aws_caller_identity.current.account_id, data.aws_region.current.region)
  bucket_namespace = "account-regional"
  force_destroy = true
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