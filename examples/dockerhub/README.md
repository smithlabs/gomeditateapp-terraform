# Example - Deploy by using the DockerHub image

This folder contains a [Terraform](https://www.terraform.io/) configuration that shows an example of how to
deploy the web app using the ``smithlabs/gomeditateapp:1.0`` [DockerHub](https://hub.docker.com/repository/docker/smithlabs/gomeditateapp) image.

Snippet from ``user-data.sh``.

``` bash
# Run the docker container in detached mode and map port 8080 on the host to 8080 in the container
# This is required so it can be accessed by a browser or external load balancer/reverse proxy
sudo docker run --restart=always --name app -d -p 8080:8080 smithlabs/gomeditateapp:1.0
```

## Pre-requisites

- You must have [Terraform](https://www.terraform.io/) installed on your computer.
- You must have an [Amazon Web Services (AWS) account](http://aws.amazon.com/).

Please note that this code was written for Terraform 0.13.x.

## Quick start

**Please note that this example will deploy real resources into your AWS account. We have made every effort to ensure
all the resources qualify for the [AWS Free Tier](https://aws.amazon.com/free/), but we are not responsible for any
charges you may incur.**

Configure your [AWS access
keys](http://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys) as
environment variables:

```
export AWS_ACCESS_KEY_ID=(your access key id)
export AWS_SECRET_ACCESS_KEY=(your secret access key)
```

Deploy the code:

```
terraform init
terraform apply
```

When the `apply` command completes, it will output the DNS name of the load balancer. Visit the ELB url in your browser.

```
terraform output
```

Clean up when you're done:

```
terraform destroy
```
