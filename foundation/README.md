# Foundation

Provisions the foundational infrastructure needed to run the plum tree.

This generally things we need only one of and/or don't change often. Examples would be:

- The underlying network infrastructure (VPCs, Subnets etc.)
- The upload input and processed buckets
- IAM roles and policies

## Before Starting

The foundation infrastructure will be the first thing you deploy as everything else build on top of this. However before you try to deploy this you'll need:

1. [An AWS account][1]
2. [A AWS user][2] and [credentials such as access keys][3] to use to deploy
3. [A S3 bucket][4] to store Terraform state
4. [Terraform installed][5]

## Deploying

Configure the AWS credentials for your AWS account.

Init terraform with the state bucket you created.

```
terraform init -backend-config="bucket=YOUR_BUCKET_NAME_HERE"
```

Run the terraform apply command.

```
terraform apply
```

Note all of this can be done via GitLab CICD. See [.gitlab-ci.yml](../.gitlab-ci.yml) for how this is configured and the variables it expects (e.g. AWS key/secret and state bucket name).


[1]: https://docs.aws.amazon.com/accounts/latest/reference/manage-acct-creating.html
[2]: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html
[3]: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html
[4]: https://docs.aws.amazon.com/AmazonS3/latest/userguide/create-bucket-overview.html
[5]: https://developer.hashicorp.com/terraform/install?product_intent=terraform