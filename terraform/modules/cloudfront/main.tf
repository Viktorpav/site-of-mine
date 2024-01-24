data "aws_region" "current" {}

resource "aws_cloudfront_origin_access_control" "cloudfront_origin_access_control" {
  name                              = var.domain_name
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "distribution" {
  origin {
    domain_name              = "${var.domain_name}.s3.${data.aws_region.current.name}.amazonaws.com"
    origin_id                = var.domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_origin_access_control.id
  }

  aliases = [
    var.domain_name,
    "www.${var.domain_name}",
  ]

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    default_ttl     = 3600
    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string = true
      headers      = ["Access-Control-Request-Headers", "Access-Control-Request-Method"]
    }
    max_ttl                = 31536000
    min_ttl                = 0
    target_origin_id       = var.domain_name
    viewer_protocol_policy = "redirect-to-https"
    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.function.arn
    }
  }

  default_root_object = "index.html"
  enabled             = true
  http_version        = "http2"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100"

  viewer_certificate {
    acm_certificate_arn      = var.domain_certificate_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  custom_error_response {
    error_code            = 404
    response_code         = 404
    response_page_path    = "/404.html"
    error_caching_min_ttl = 60
  }

  custom_error_response {
    error_code            = 403
    response_code         = 403
    response_page_path    = "/404.html"
    error_caching_min_ttl = 60
  }

  custom_error_response {
    error_code            = 503
    response_code         = 503
    response_page_path    = "/503.html"
    error_caching_min_ttl = 5
  }

  logging_config {
    bucket          = var.s3_logs_bucket.domain_name
    include_cookies = false
    prefix          = "cloudfront-logs/"
  }

  restrictions {
    geo_restriction {
      restriction_type = "blacklist"
      locations        = ["RU"]
    }
  }
}

resource "aws_cloudfront_function" "function" {
  name    = "${var.prefix}-www-redirects"
  comment = "Redirect to www.${var.domain_name}"
  runtime = "cloudfront-js-2.0"
  code    = file("${path.module}/redirect_function.js")
}

data "aws_route53_zone" "domain_zone" {
  name = var.domain_name
}

resource "aws_route53_record" "www_record" {
  zone_id = data.aws_route53_zone.domain_zone.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
