# Get account ID to make the input and processed bucket names globally unique
data "aws_caller_identity" "current" {}