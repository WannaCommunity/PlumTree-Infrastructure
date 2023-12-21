# All user uploads land in the input bucket. If a item is saved the images is
# moved to the processed bucket. Otherwise items in the input bucket are deleted
# after 1 day.
resource "aws_s3_bucket" "input_bucket" {
  bucket = "upload-input-${data.aws_caller_identity.current.account_id}"
  tags   = {
    Name        = "upload-input-${data.aws_caller_identity.current.account_id}"
    Description = "Temp bucket to store uploads and their edits such as cropping"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "temp" {
  bucket = aws_s3_bucket.input_bucket.id

  rule {
    id     = "temp"
    status = "Enabled"

    expiration {
      days = 1
    }
  }
}

# Add cors rules so we can upload via pre-signed URLs
resource "aws_s3_bucket_cors_configuration" "upload" {
  bucket = aws_s3_bucket.input_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_public_access_block" "input_bucket" {
  block_public_acls       = false
  block_public_policy     = false
  bucket                  = aws_s3_bucket.input_bucket.id
  ignore_public_acls      = false
  restrict_public_buckets = false
}
