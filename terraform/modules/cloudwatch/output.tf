output "cloudbuild_log" {
  value = {
    name = aws_cloudwatch_log_group.cloudbuild_log.name
    arn  = aws_cloudwatch_log_group.cloudbuild_log.arn
  }
}
