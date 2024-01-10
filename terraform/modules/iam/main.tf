#Policies for S3 Website bucket
resource "aws_iam_policy" "s3_access_policy" {
  name        = "${var.prefix}-S3AccessPolicy"
  description = "Provides access to the S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          "${var.s3_website_bucket}/*",
          "${var.s3_website_bucket}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_access_attachment" {
  role       = aws_iam_role.codepipeline_role.name # Replace with your CodePipeline or CodeBuild role
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

#Policies for S3 deployment bucket
resource "aws_iam_policy" "s3_deployment_access_policy" {
  name        = "${var.prefix}-S3DeploymentAccessPolicy"
  description = "Provides access to the S3 Deployment bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          "${var.s3_deployment_bucket}/*",
          "${var.s3_deployment_bucket}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_deployment_access_attachment" {
  role       = aws_iam_role.codepipeline_role.name # Replace with your CodePipeline or CodeBuild role
  policy_arn = aws_iam_policy.s3_deployment_access_policy.arn
}

#Role and policies for CodePipeline and CodeStar connection
resource "aws_iam_role" "codepipeline_role" {
  name = "${var.prefix}-CodePipelineRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "codepipeline.amazonaws.com"
      },
      Action = ["sts:AssumeRole"]
    }]
  })
}

# Policy for CodePipeline role to allow CodeBuild
resource "aws_iam_policy" "codepipeline_codebuild_policy" {
  name        = "${var.prefix}-CodePipelineCodeBuildPolicy"
  description = "Provides access for CodePipeline role to allow CodeBuild"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "codebuild:StartBuild",
        Resource = "${var.codebuild_project}/*",
      }
    ]
  })
}

# Attach the CodePipelineCodeBuildPolicy to CodePipelineRole
resource "aws_iam_role_policy_attachment" "codepipeline_codebuild_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_codebuild_policy.arn
}

resource "aws_iam_role" "codebuild_role" {
  name = "${var.prefix}-CodeBuildRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "codebuild.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "codestar_policy" {
  name        = "${var.prefix}-CodeStarConnections"
  description = "Provides full access to AWS CodeStar connections"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = "codestar-connections:*",
      Resource = "*",
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codestar_policy.arn
}

# #Policy for CodeBuild
# resource "aws_iam_policy" "codepipeline_codebuild_policy" {
#   name = "${var.prefix}-CodePipelineCodeBuildPolicy"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect   = "Allow",
#         Action   = "codebuild:StartBuild",
#         Resource = "${var.codebuild_project}/*",
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "codepipeline_codebuild_attachment" {
#   role       = aws_iam_role.codepipeline_role.name
#   policy_arn = aws_iam_policy.codepipeline_codebuild_policy.arn
# }
