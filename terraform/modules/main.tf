# Variables that are being passed in
variable "prefix" {}

// this is S3 bucket creation for storing tfstate file
resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.prefix}-terraform-up-and-running-state"

  // prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name = "${var.prefix}_terraform_up_and_running_state"
  }
}

// turn server-side encryption on by default for all data written to this S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

// block all public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
