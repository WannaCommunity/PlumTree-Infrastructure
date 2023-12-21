locals {
  name_prefix = "plum-tree-${terraform.workspace}"
}

provider "aws" {
  region = "eu-west-1"

  default_tags {
   tags = {
     Application = "plum-tree",
     Environment = terraform.workspace
     Component   = "application"
   }
 }
}

terraform {
  backend "s3" {
    key    = "application/terraform.tfstate"
    region = "eu-west-1"
  }
}
