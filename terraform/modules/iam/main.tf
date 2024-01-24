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
resource "aws_iam_policy" "codepipeline_policy" {
  name        = "${var.prefix}-CodePipelinePolicy"
  description = "A policy with permissions for CodePipeline"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Effect   = "Allow",
        Action   = ["codestar-connections:UseConnection"],
        Resource = "${var.codestar_connection}"
      },
      {
        Effect   = "Allow",
        Action   = ["codebuild:StartBuild", "codebuild:BatchGetBuilds"],
        Resource = "${var.codebuild_project}"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObjectAcl",
          "s3:PutObject"
        ],
        Resource = ["${var.s3_deployment_bucket}", "${var.s3_deployment_bucket}/*"]
      },
      {
        Effect   = "Allow",
        Action   = ["codedeploy:CreateDeployment", "codedeploy:GetDeploymentConfig"],
        Resource = "${var.codebuild_project}"
      }
    ]
  })
}


# Attach policy to the CodePipelineRole
resource "aws_iam_role_policy_attachment" "codepipeline_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_policy.arn
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

resource "aws_iam_policy" "codebuild_policy" {
  name        = "${var.prefix}-CodeBuildPolicy"
  description = "A policy with permissions for CodeBuild"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Effect   = "Allow",
        Action   = ["codebuild:*"],
        Resource = "${var.codebuild_project}"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        Resource = ["${var.cloudbuild_log}", "${var.cloudbuild_log}:*"]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        Resource = [
          "${var.s3_website_bucket.arn}",
          "${var.s3_website_bucket.arn}/*",
          "${var.s3_deployment_bucket}",
          "${var.s3_deployment_bucket}/*"
        ]
      },
      {
        Effect   = "Allow",
        Action   = ["cloudfront:CreateInvalidation"],
        Resource = "${var.cloudfront_distribution}"
      }
    ]
  })
}

# Attach policy to the CodeBuildRole
resource "aws_iam_role_policy_attachment" "codebuild_attachment" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_policy.arn
}

resource "aws_s3_bucket_policy" "logs_bucket_policy" {
  bucket = var.s3_logs_bucket.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = ["s3:PutObject", "s3:GetObject"],
        Resource  = ["${var.s3_logs_bucket.arn}/*"],
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "site_bucket_policy" {
  bucket = var.s3_website_bucket.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipal",
        Effect    = "Allow",
        Principal = { Service = "cloudfront.amazonaws.com" },
        Action    = "s3:GetObject",
        Resource  = ["${var.s3_website_bucket.arn}/*"],
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = [var.cloudfront_distribution]
          }
        }
      }
    ]
  })
}
