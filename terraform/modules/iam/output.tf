output "codepipeline_role_arn" {
  description = "The Codepipeline ARN"
  value       = aws_iam_role.codepipeline_role.arn
}

output "codebuild_role_arn" {
  description = "The Codepipeline ARN"
  value       = aws_iam_role.codebuild_role.arn
}

