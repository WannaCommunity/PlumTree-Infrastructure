resource "aws_iam_policy" "uploads_s3_policy" {
  name        = "plum-tree-uploads-bucket-access"
  description = "Access to upload buckets"
  policy      = data.aws_iam_policy_document.uploads_s3_policy.json
}

data "aws_iam_policy_document" "uploads_s3_policy" {
  statement {
    sid = "ReadWrite"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:DeleteObject",
    ]

    resources = [
      aws_s3_bucket.input_bucket.arn,
      aws_s3_bucket.upload_processed.arn,
      "${aws_s3_bucket.input_bucket.arn}/*",
      "${aws_s3_bucket.upload_processed.arn}/*",
    ]
  }

  statement {
    sid = "ObjectACLs"

    actions = [
      "s3:PutObjectVersionAcl",
      "s3:PutObjectAcl",
    ]

    resources = [
      "arn:aws:s3:::*/*",
    ]
  }

  statement {
    sid = "ListBuckets"

    actions = [
      "s3:ListAllMyBuckets",
      "s3:HeadBucket",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    sid = "Tagging"

    actions = [
      "s3:GetObjectTagging",
      "s3:DeleteObjectTagging",
      "s3:PutObjectTagging",
      "s3:ReplicateTags"
    ]

    resources = [
      "*",
    ]
  }
}
