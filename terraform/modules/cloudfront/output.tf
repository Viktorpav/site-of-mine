output "cloudfront_distribution" {
  value = {
    id          = aws_cloudfront_distribution.distribution.id
    arn         = aws_cloudfront_distribution.distribution.arn
    domain_name = aws_cloudfront_distribution.distribution.domain_name
  }
}
