provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

resource "aws_acm_certificate" "domain_certificate" {
  provider          = aws.us_east_1 # Use the alias for the us-east-1 provider
  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = [
    var.domain_name,
    "www.${var.domain_name}"
  ]

  tags = {
    Name = "Domain Certificate"
  }

  lifecycle {
    create_before_destroy = true
  }
}
