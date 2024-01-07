variable "prefix" {}
variable "domain_name" {}


variable "github_token" {
  description = "GitHub access token"
}

variable "github_owner" {
  description = "GitHub repository owner"
  default     = "your_username" # Replace with your GitHub username
}

variable "github_repo" {
  description = "GitHub repository name"
  default     = "your_repo" # Replace with your GitHub repository name
}

variable "s3_bucket_name" {
  description = "S3 bucket name for deployment"
  default     = "your-s3-bucket" # Replace with your S3 bucket name
}

variable "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  default     = "your-cloudfront-distribution-id" # Replace with your CloudFront distribution ID
}

