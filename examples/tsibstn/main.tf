provider "aws" {
  region = "ap-southeast-1"
}

locals {
  vpc_id       = data.aws_vpc.this.id
  environment  = "staging"
  product      = "tsi"
  asg_capacity = "1"
}

module "this" {
  source       = "../../"
  environment  = local.environment
  product      = local.product
  vpc_id       = local.vpc_id
  asg_capacity = local.asg_capacity
  description  = "bastion for ${local.product}"
}
