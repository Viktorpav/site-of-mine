# Define variables with default values and descriptions
variable "region" {
  description = "The AWS region to deploy resources."
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "The AWS profile for authentication."
  default     = "default"
}

variable "prefix" {
  description = "The prefix used for naming resources."
  default     = "my-project"
}
