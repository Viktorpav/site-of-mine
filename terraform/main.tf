terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0"
    }
  }

  # Required version of Terraform
  required_version = "~> 1.6.6"
}

# AWS provider with region and profile set to the
# region and aws_profile variables
provider "aws" {
  region  = var.region
  profile = var.aws_profile

  endpoints {
    sts = "https://sts.${var.region}.amazonaws.com"
  }
}


// The S3 module to store tfstate file in S3 backet as a backup 
module "s3" {
  source                 = "./modules/s3"
  prefix                 = var.prefix
  domain_name            = var.domain_name
  transcode_function_arn = module.lambda.transcode_function_arn
}

module "lambda" {
  source      = "./modules/lambda"
  prefix      = var.prefix
  domain_name = var.domain_name
}

module "cloudfront" {
  source                 = "./modules/cloudfront"
  prefix                 = var.prefix
  domain_name            = var.domain_name
  domain_certificate_arn = module.acm.domain_certificate_arn
}

module "acm" {
  source      = "./modules/acm"
  prefix      = var.prefix
  domain_name = var.domain_name
}

module "iam" {
  source               = "./modules/iam"
  prefix               = var.prefix
  domain_name          = var.domain_name
  s3_website_bucket    = module.s3.s3_website_bucket.arn
  s3_deployment_bucket = module.s3.s3_deployment_bucket.arn
  codebuild_project    = module.codebuild.codebuild_project.arn
}

module "codepipeline" {
  source                = "./modules/codepipeline"
  prefix                = var.prefix
  domain_name           = var.domain_name
  github_owner          = var.github_owner
  github_repo           = var.github_repo
  branch_name           = var.branch_name
  codepipeline_role_arn = module.iam.codepipeline_role_arn
  s3_deployment_bucket  = module.s3.s3_deployment_bucket.name
  codebuild_project     = module.codebuild.codebuild_project.name
}

module "codebuild" {
  source                     = "./modules/codebuild"
  prefix                     = var.prefix
  domain_name                = var.domain_name
  cloudfront_distribution_id = module.cloudfront.cloudfront_distribution_id
  codebuild_role_arn         = module.iam.codebuild_role_arn
  s3_website_bucket          = module.s3.s3_website_bucket.name
  cloudbuild_log             = module.cloudwatch.cloudbuild_log
}

module "cloudwatch" {
  source      = "./modules/cloudwatch"
  prefix      = var.prefix
  domain_name = var.domain_name
}
