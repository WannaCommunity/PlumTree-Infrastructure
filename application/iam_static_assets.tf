data "aws_iam_policy_document" "assets_s3_policy" {
  statement {
    actions = [
      "s3:Get*",
      "s3:List*",
    ]

    resources = [
      aws_s3_bucket.static_assets.arn,
      "${aws_s3_bucket.static_assets.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "assets_s3_policy" {
  name        = "${local.name_prefix}-asset-bucket-access"
  description = "Read only access for Plum Tree ${terraform.workspace} static assets bucket"
  policy      = data.aws_iam_policy_document.assets_s3_policy.json
}

data "aws_iam_policy_document" "assets_s3_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "assets_s3_api_gateyway_role" {
  name = "${local.name_prefix}-gateway-assets-s3-role"
  assume_role_policy = data.aws_iam_policy_document.assets_s3_assume_role.json
}

resource "aws_iam_role_policy_attachment" "assets_s3_policy_attach" {
  role       = aws_iam_role.assets_s3_api_gateyway_role.name
  policy_arn = aws_iam_policy.assets_s3_policy.arn
}
