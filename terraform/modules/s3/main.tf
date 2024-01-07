resource "aws_s3_bucket" "site_bucket" {
  bucket = var.domain_name

  lifecycle {
    prevent_destroy = true
  }
}

# Configure the Lambda notifications
# Replace the placeholders with the actual ARN of the Lambda function
# for the respective file types

# Add similar blocks for other file types (.mp4, .avi, etc.)
resource "aws_s3_bucket_notification" "site_bucket_notification" {
  bucket = aws_s3_bucket.site_bucket.id

  lambda_function {
    lambda_function_arn = var.transcode_function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ".mp4"
  }
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
    allowed_origins = ["https://www.${var.domain_name}"]
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_policy" "site_bucket_policy" {
  bucket = aws_s3_bucket.site_bucket.bucket

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "Grant CloudFront Origin Access Control access to S3 bucket",
        Effect    = "Allow",
        Principal = { Service = "cloudfront.amazonaws.com" },
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.site_bucket.arn}/*"
      },
      {
        Sid       = "Deny non-secure transport",
        Effect    = "Deny",
        Principal = "*",
        Action    = "s3:*",
        Resource  = "${aws_s3_bucket.site_bucket.arn}/*",
        Condition = {
          Bool = { "aws:SecureTransport" = false }
        }
      }
    ]
  })
}
