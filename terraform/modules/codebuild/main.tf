resource "aws_codebuild_project" "deploy_project" {
  name         = "${var.prefix}-deploy-to-s3-codebuild"
  description  = "CodeBuild project for deploying to S3"
  service_role = var.codebuild_role_arn

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type = "NO_SOURCE"
    buildspec = templatefile("${path.module}/buildspec.yaml", {
      bucket_name                = var.s3_website_bucket
      cloudfront_distribution_id = var.cloudfront_distribution_id
    })
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  logs_config {
    cloudwatch_logs {
      group_name = var.cloudbuild_log
      status     = "ENABLED"
    }
  }
}


