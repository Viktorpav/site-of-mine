variable "prefix" {}
variable "domain_name" {}
variable "s3_deployment_bucket" {}
variable "s3_website_bucket" {
  type = object({
    name = string
    arn  = string
  })
}
variable "s3_logs_bucket" {}
variable "codebuild_project" {}
variable "cloudbuild_log" {}
variable "codestar_connection" {}
variable "cloudfront_distribution" {}
