# S3 bucket for CloudPipeline deployment
resource "aws_s3_bucket" "deployment_bucket" {
  bucket = "${var.prefix}-deployment"
}

# S3 bucket for S3 logs and CloudFront
resource "aws_s3_bucket" "logs_bucket" {
  bucket = "${var.prefix}-logs"
}

resource "aws_s3_bucket_logging" "site_bucket_logs" {
  bucket = aws_s3_bucket.site_bucket.id

  target_bucket = aws_s3_bucket.logs_bucket.id
  target_prefix = "s3-logs/"
}

# S3 bucket for Website
resource "aws_s3_bucket" "site_bucket" {
  bucket = var.domain_name
}

resource "aws_s3_bucket_server_side_encryption_configuration" "site_bucket_encryption" {
  bucket = aws_s3_bucket.site_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_cors_configuration" "site_bucket_cors" {
  bucket = aws_s3_bucket.site_bucket.id

  cors_rule {
    allowed_origins = [
      "https://${var.domain_name}",
      "https://www.${var.domain_name}",
    ]
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    max_age_seconds = 3000
  }
}

# Add similar blocks for other file types (.mp4, .avi, etc.)
resource "aws_s3_bucket_notification" "site_bucket_notification" {
  bucket = aws_s3_bucket.site_bucket.id

  lambda_function {
    lambda_function_arn = var.transcode_function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ".mp4"
  }

  lambda_function {
    lambda_function_arn = var.transcode_function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ".avi"
  }
}
