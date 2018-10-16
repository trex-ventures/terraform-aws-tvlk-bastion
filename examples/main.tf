locals {
  vpc_id = "vpc-aa11bb22"
}

module "this" {
  source                     = "../../terraform-aws-tvlk-bastion"
  service_name               = "tsibstn"
  environment                = "production"
  product_domain             = "tsi"
  vpc_id                     = "${local.vpc_id}"
  subnet_name                = "my-private-subnet"
  ami_account_owner          = "aa11bb22cc33dd44"
  session_manager_bucket_arn = "arn:aws:s3:::bucket-to-store-session-manager-logs"
  sg_id                      = ["${aws_security_group.this.id}"]
}

resource "aws_security_group" "this" {
  name        = "tsisesm-bastion"
  description = "security group for tsisesm-bastion"
  vpc_id      = "${local.vpc_id}"
}

resource "aws_security_group_rule" "allow_all_egress_http" {
  type              = "egress"
  protocol          = "tcp"
  from_port         = "80"
  to_port           = "80"
  security_group_id = "${aws_security_group.this.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow egress access to http port 80 to internet"
}

resource "aws_security_group_rule" "allow_all_egress_https" {
  type              = "egress"
  protocol          = "tcp"
  from_port         = "443"
  to_port           = "443"
  security_group_id = "${aws_security_group.this.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow egress access to https port 443 to internet"
}
