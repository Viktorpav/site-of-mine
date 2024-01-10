output "s3_website_bucket" {
  value = {
    name = aws_s3_bucket.site_bucket.bucket
    arn  = aws_s3_bucket.site_bucket.arn
  }
}

output "s3_deployment_bucket" {
  value = {
    name = aws_s3_bucket.deployment_bucket.bucket
    arn  = aws_s3_bucket.deployment_bucket.arn
  }
}
