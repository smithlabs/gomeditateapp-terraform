# ---------------------------------------------------------------------------------------------------------------------
# VERSIONING
# This project was written for Terraform 0.13.x
# See 'Upgrading to Terraform v0.13' https://www.terraform.io/upgrade-guides/0-13.html
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.13"
}

provider "aws" {
  region = "us-east-1"

  # Allow any 2.x version of the AWS provider
  version = "~> 2.0"
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULES
# These are my custom Terraform modules and they should be pinned to v1.0.0.0.
# ---------------------------------------------------------------------------------------------------------------------

module "elb" {
  source = "github.com/smithlabs/terraform-aws-elb?ref=v1.0.0"

  elb_name   = var.name
  subnet_ids = data.aws_subnet_ids.default.ids
}

module "asg" {
  source = "github.com/smithlabs/terraform-aws-asg-rolling-deploy?ref=v1.0.0"

  ami            = "ami-02354e95b39ca8dec" # Amazon Linux
  instance_type  = "t2.micro"
  name           = var.name
  environment    = var.environment
  user_data      = data.template_file.user_data.rendered
  min_size       = 2
  max_size       = 2
  subnet_ids     = data.aws_subnet_ids.default.ids
  load_balancers = [module.elb.elb_name]
}

# ---------------------------------------------------------------------------------------------------------------------
# ELB SECURITY GROUP RULES
# Allow traffic from the outside world to reach the web application
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group_rule" "allow_elb_http_inbound" {
  type              = "ingress"
  security_group_id = module.elb.elb_security_group_id

  from_port   = local.http_port
  to_port     = local.http_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_elb_all_outbound" {
  type              = "egress"
  security_group_id = module.elb.elb_security_group_id

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips
}

# ---------------------------------------------------------------------------------------------------------------------
# ASG SECURITY GROUP RULES
# Allow the EC2 instance to bootstrap and be added to the ELB cluster
# ---------------------------------------------------------------------------------------------------------------------

# Allow traffic to the server port for the web application
resource "aws_security_group_rule" "allow_server_http_inbound" {
  type              = "ingress"
  security_group_id = module.asg.instance_security_group_id

  from_port   = var.server_port
  to_port     = var.server_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

# Allow the EC2 instance to reach the Internet to perform the server setup in user-data.sh
resource "aws_security_group_rule" "allow_server_all_outbound" {
  type              = "egress"
  security_group_id = module.asg.instance_security_group_id

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips
}

# ---------------------------------------------------------------------------------------------------------------------
# ADDITIONAL CONFIGURATION
# ---------------------------------------------------------------------------------------------------------------------

locals {
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]
}

data "template_file" "user_data" {
  template = file("${path.module}/user-data.sh")
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

# ---------------------------------------------------------------------------------------------------------------------
# ROUTE53
# ---------------------------------------------------------------------------------------------------------------------

data "aws_route53_zone" "selected" {
    name        =    "gomeditateapp.com."
  }

  resource "aws_route53_record" "main" {
    zone_id = data.aws_route53_zone.selected.zone_id
    name    = "gomeditateapp.com"
    type    = "A"

    alias {
      name                   = module.elb.elb_dns_name
      zone_id                = module.elb.elb_zone_id
      evaluate_target_health = false
    }
  }

  resource "aws_route53_record" "www" {
    zone_id = data.aws_route53_zone.selected.zone_id
    name    = "www.gomeditateapp.com"
    type    = "A"

    alias {
      name                   = module.elb.elb_dns_name
      zone_id                = module.elb.elb_zone_id
      evaluate_target_health = false
    }
  }


# ---------------------------------------------------------------------------------------------------------------------
# DEV RECORD WITH ACM
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_acm_certificate" "selected" {
  domain_name        = "dev.gomeditateapp.com"
  validation_method = "DNS"
}

resource "aws_route53_record" "dev" {
  for_each = {
        for dvo in aws_acm_certificate.selected.domain_validation_options : dvo.domain_name => {
          name          = dvo.resource_record_name
          record        = dvo.resource_record_value
          type          = dvo.resource_record_type
        }
}

 allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.selected.zone_id
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.selected.arn
  validation_record_fqdns = [for record in aws_route53_record.dev : record.fqdn]
}

resource "aws_route53_record" "site" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "dev.gomeditateapp.com"
  type    = "A"

  alias {
    name                   = module.elb.elb_dns_name
    zone_id                = module.elb.elb_zone_id
    evaluate_target_health = false
  }
}
