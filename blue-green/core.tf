provider "aws" {
  region = "eu-west-1"

  default_tags {
   tags = {
     Application = "plum-tree",
     Environment = terraform.workspace
     Component   = "blue-green"
   }
 }
}

terraform {
  backend "s3" {
    key    = "blue-green/terraform.tfstate"
    region = "eu-west-1"
  }
}

module "blue_green" {
  source = "../modules/blue-green"
  color  = var.color
  domain = var.domain
}
