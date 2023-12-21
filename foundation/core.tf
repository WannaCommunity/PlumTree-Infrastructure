locals {
  name_prefix = "plum-tree-${terraform.workspace}"
  cidr        = "172.17.0.0/20"
}

provider "aws" {
  region = "eu-west-1"

  default_tags {
   tags = {
     Application = "plum-tree",
     Environment = terraform.workspace
     Component   = "foundation"
   }
 }
}

terraform {
  backend "s3" {
    key    = "foundation/terraform.tfstate"
    region = "eu-west-1"
  }
}

module "network" {
  source = "../modules/network"
  cidr   = local.cidr
}

module "vpc_endpoints" {
  source = "../modules/vpc_endpoints"

  gateway_service_names = [
    "s3"
  ]
  interface_service_names = [
    "email-smtp"
  ]
  subnet_ids      = module.network.private_subnets
  route_table_ids = module.network.private_route_tables
}

module "upload_buckets" {
  source = "../modules/upload_buckets"
}

resource "aws_iam_policy" "send_mail_s3_policy" {
  name        = "plum-tree-send-mail"
  description = "Access to send emails via SES"
  policy      = data.aws_iam_policy_document.send_mail_s3_policy.json
}

data "aws_iam_policy_document" "send_mail_s3_policy" {
  statement {
    sid = "SendMail"

    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail",
    ]

    resources = [
      "*",
    ]
  }
}
