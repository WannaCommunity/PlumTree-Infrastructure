data "aws_iam_policy_document" "uploads_s3_policy" {
  statement {
    actions = [
      "s3:Get*",
      "s3:List*",
    ]

    resources = [
      data.aws_s3_bucket.uploads_bucket.arn,
      "${data.aws_s3_bucket.uploads_bucket.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "uploads_s3_policy" {
  name        = "${local.name_prefix}-uploads-bucket-access"
  description = "Read only access for Plum Tree ${terraform.workspace} uploads bucket"
  policy      = data.aws_iam_policy_document.uploads_s3_policy.json
}

data "aws_iam_policy_document" "uploads_s3_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "uploads_s3_api_gateyway_role" {
  name = "${local.name_prefix}-gateway-uploads-s3-role"
  assume_role_policy = data.aws_iam_policy_document.uploads_s3_assume_role.json
}

resource "aws_iam_role_policy_attachment" "uploads_s3_policy_attach" {
  role       = aws_iam_role.uploads_s3_api_gateyway_role.name
  policy_arn = aws_iam_policy.uploads_s3_policy.arn
}
