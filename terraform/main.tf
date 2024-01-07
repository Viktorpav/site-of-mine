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
