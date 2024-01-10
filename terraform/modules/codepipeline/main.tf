resource "aws_codestarconnections_connection" "github_connection" {
  name          = "${var.prefix}-S3GitHub"
  provider_type = "GitHub"
}

resource "aws_codepipeline" "s3_pipeline" {
  name     = "${var.prefix}-github-to-s3-pipeline"
  role_arn = var.codepipeline_role_arn

  artifact_store {
    location = var.s3_deployment_bucket # Replace with your S3 bucket for pipeline artifacts
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github_connection.arn
        FullRepositoryId = var.github_repo
        BranchName       = var.branch_name
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output"]


      configuration = {
        ProjectName = var.codebuild_project
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        BucketName = var.domain_name
        Extract    = "true"
      }
    }
  }
}

