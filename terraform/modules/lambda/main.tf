resource "aws_iam_role" "transcode_function_role" {
  name = "${var.prefix}-TranscodeFunctionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action    = "sts:AssumeRole",
    }],
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
  ]

  inline_policy {
    name = "S3PermissionsLambda"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [{
        Effect   = "Allow",
        Action   = ["s3:GetObject", "s3:PutObject"],
        Resource = "arn:aws:s3:::${var.domain_name}/*",
      }],
    })
  }
}

resource "aws_lambda_layer_version" "ffmpeg_layer" {
  filename                 = "${path.module}/lambda-layers/ffmpeg-layer.zip"
  layer_name               = "${var.prefix}-FFmpegLayer"
  compatible_runtimes      = ["python3.10"]
  compatible_architectures = ["arm64"]
}

resource "aws_lambda_function" "transcode_function" {
  function_name = "${var.prefix}-transcode-function"
  handler       = "index.lambda_handler"
  runtime       = "python3.10"
  timeout       = 900
  memory_size   = 2048
  role          = aws_iam_role.transcode_function_role.arn
  layers        = [aws_lambda_layer_version.ffmpeg_layer.arn]

  filename = "${path.module}/lambda-function/transcode_function.zip" # Replace with the actual path to your Lambda code ZIP file

  environment {
    variables = {
      KEY = "VALUE" # Replace with environment variables needed by your Lambda function
    }
  }
}

data "aws_caller_identity" "current" {}

resource "aws_lambda_permission" "s3_invoke_lambda_permission" {
  statement_id   = "AllowExecutionFromS3Bucket"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.transcode_function.arn
  principal      = "s3.amazonaws.com"
  source_arn     = "arn:aws:s3:::${var.domain_name}"
  source_account = data.aws_caller_identity.current.account_id
}
