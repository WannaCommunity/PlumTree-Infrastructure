# Blue Green

Creates the infrastructure so we can perform blue/green deploys for the plum tree.

The [application infrastructure](../application/) can be deployed to any number of colors (or stacks) as needed and the blue-green infrastructure here serves as a single point of entry to one of those stacks.

This works by setting up a CloudFront distribution where we update the origin to be one of the colors (or stacks) for the application.

## Before Starting

The blue-green infrastructure is deployed after the [application infrastructure](../application/). Once you've done that here you will need to make a note of the colors you deployed (e.g. blue, green, batman it doesn't really matter what you called them).

## Deploying

Configure the AWS credentials for your AWS account.

Init terraform with the state bucket you created.

```
terraform init -backend-config="bucket=YOUR_BUCKET_NAME_HERE"
```

Run the terraform apply command. When prompted for a color enter the color of the application stack you want to make active.

```
terraform apply
var.color
  The color to release

  Enter a value: blue
```

Note all of this can be done via GitLab CICD. See [.gitlab-ci.yml](../.gitlab-ci.yml) for how this is configured and the variables it expects (e.g. AWS key/secret, color and domain).
