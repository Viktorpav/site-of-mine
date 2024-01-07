output "domain_certificate_arn" {
  description = "The Certificate ARN"
  value       = aws_acm_certificate.domain_certificate.arn
}
