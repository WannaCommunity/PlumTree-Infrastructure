# Application

Provisions the application infrastructure on top of the [foundational infrastructure](../foundation/). The plum tree application infrastructure is designed to allow for multiple copies named "colors". The end result is you can deploy to one of these colors and access the stack at `<color>.<plumtreedomain>` (e.g. `https://blue.theplumtreeapp.com`).

The application infrastructure does not include the application code itself. Just the infrastructure that code can be deployed to. See [ui][1] and [api][2] repo for the actual application code.

This infrastructure at a high level includes:

1. The AWS API Gateway to deploy api endpoints to
2. The S3 bucket to deploy the ui to
3. The Route53 DNS entries for the color/stack subdomains

## Before Starting

The application infrastructure is deployed after the [foundation infrastructure](../foundation/). Once you've done that here you will need to **register a domain**.

If you [register a domain via AWS][3] a hosted zone will be created for you and you won't have to do anything else.

If you register a domain elsewhere you'll need to create a hosted zone for it and update the name server settings to point to the ones in the AWS hosted zone you created.

## Deploying

Configure the AWS credentials for your AWS account.

Init terraform with the state bucket you created.

```
terraform init -backend-config="bucket=YOUR_BUCKET_NAME_HERE"
```

Select a terraform workspace (create one if not done so already).

```
terraform workspace new blue
terraform workspace select blue
```

Run the terraform apply command.

```
terraform apply
```

Note all of this can be done via GitLab CICD. See [.gitlab-ci.yml](../.gitlab-ci.yml) for how this is configured and the variables it expects (e.g. AWS key/secret, color and domain).


[1]: https://gitlab.com/plum-tree/ui
[2]: https://gitlab.com/plum-tree/api
[3]: https://us-east-1.console.aws.amazon.com/route53/domains/home?region=eu-west-1#/DomainSearch