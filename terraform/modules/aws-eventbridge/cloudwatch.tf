resource "aws_cloudwatch_log_group" "purplelab-alerts" {
  name = "purplelab-alerts"
  retention_in_days = 30
}