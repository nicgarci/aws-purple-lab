resource "aws_lambda_function" "telegram_alerter" {
  function_name = "purplelab_telegram_alerter"
  handler = "telegram_alerter.lambda_handler"
  runtime = "python3.14"
  role = aws_iam_role.lambda_role.arn
  filename = "./modules/aws-eventbridge/telegram_alerter.zip"
  logging_config {
    log_format = "JSON"
    application_log_level = "INFO"
    system_log_level = "INFO"
    log_group = aws_cloudwatch_log_group.purplelab_alerter_log_group.name
  }
  depends_on = [ aws_cloudwatch_log_group.purplelab_alerter_log_group ]
}