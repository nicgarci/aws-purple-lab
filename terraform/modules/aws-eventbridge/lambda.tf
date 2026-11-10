resource "aws_lambda_function" "telegram_alerter" {
  function_name = "purplelab_telegram_alerter"
  handler = "lambda_function.lambda_handler"
  runtime = "python3.14"
  role = aws_iam_role.lambda_role.arn
  filename = "./modules/aws-eventbridge/telegram_alerter.zip"
}