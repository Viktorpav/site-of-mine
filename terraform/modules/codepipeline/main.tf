resource "aws_codepipeline" "my_pipeline" {
  name     = "github-to-s3-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn # Define a role for CodePipeline

  artifact_store {
    location = "your-bucket-for-artifacts" # Replace with your S3 bucket for pipeline artifacts
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "SourceAction"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner                = var.github_owner
        Repo                 = var.github_repo
        Branch               = "main" # Replace with your branch name
        OAuthToken           = var.github_token
        PollForSourceChanges = "true"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "DeployToS3"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]

      configuration = {
        ProjectName = aws_codebuild_project.deploy_project.name
      }
    }
  }
}

