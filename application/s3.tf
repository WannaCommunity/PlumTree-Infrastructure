# Statics bucket for frontend
resource "aws_s3_bucket" "static_assets" {
  bucket = "${terraform.workspace}-assets-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name        = "${terraform.workspace}-assets-${data.aws_caller_identity.current.account_id}"
    Description = "Bucket to hold the static assets for the ${terraform.workspace} stack"
  }
}

resource "aws_s3_bucket_public_access_block" "static_assets" {
  block_public_acls       = true
  block_public_policy     = true
  bucket                  = aws_s3_bucket.static_assets.id
  ignore_public_acls      = true
  restrict_public_buckets = true
}
