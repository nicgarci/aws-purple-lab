resource "aws_cloudtrail" "purplelab" {
  name = "purplelab-trail"
  s3_bucket_name = aws_s3_bucket.purplelab.id
  is_multi_region_trail = true
  include_global_service_events = true
  enable_log_file_validation = true

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.purplelab.arn}:*"
  cloud_watch_logs_role_arn = aws_iam_role.cloudtrail_cloudwatch_role.arn

  depends_on = [ aws_s3_bucket_policy.cloudtrail_s3_bucket_access_policy ]
}