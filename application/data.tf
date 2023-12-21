# Get account ID to make the static assets bucket names globally unique
data "aws_caller_identity" "current" {}

data "aws_s3_bucket" "uploads_bucket" {
  bucket = "upload-processed-${data.aws_caller_identity.current.account_id}"
}

data "aws_s3_bucket" "uploads_input_bucket" {
  bucket = "upload-input-${data.aws_caller_identity.current.account_id}"
}
