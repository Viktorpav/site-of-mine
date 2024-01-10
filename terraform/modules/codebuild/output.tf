output "codebuild_project" {
  value = {
    name = aws_codebuild_project.deploy_project.name
    arn  = aws_codebuild_project.deploy_project.arn
  }
}
