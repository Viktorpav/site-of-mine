resource "aws_cloudwatch_log_group" "cloudbuild_log" {
  name              = "/aws/codebuild/${var.prefix}"
  retention_in_days = 30
}
