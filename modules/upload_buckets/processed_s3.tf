resource "aws_s3_bucket" "upload_processed" {
  bucket = "upload-processed-${data.aws_caller_identity.current.account_id}"
  tags   = {
    Name        = "upload-processed-${data.aws_caller_identity.current.account_id}"
    Description = "Uploads bucket where user submitted images land once processed"
  }
}

resource "aws_s3_bucket_public_access_block" "upload_processed" {
  block_public_acls       = true
  block_public_policy     = true
  bucket                  = aws_s3_bucket.upload_processed.id
  ignore_public_acls      = true
  restrict_public_buckets = true
}
