resource "aws_cloudwatch_log_group" "purplelab" {
  name = "purplelab"
  retention_in_days = 90
}