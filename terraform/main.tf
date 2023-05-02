terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.60.0"
    }
  }

  # Required version of Terraform
  required_version = "~> 1.4.2"
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
  source = "./modules/s3"
  prefix = var.prefix
}
