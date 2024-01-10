output "cloudbuild_log" {
  description = "The CloudWatch log name for CodeBuild"
  value       = aws_cloudwatch_log_group.cloudbuild_log.name
}
