# ASG
locals {
  name = "${substr(var.product, 0, 3)}bstn"
}
module "aws-autoscaling_bastion_asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 4.0"


  name                      = local.name
  min_size                  = var.asg_capacity
  max_size                  = var.asg_capacity
  desired_capacity          = var.asg_capacity
  wait_for_capacity_timeout = 0
  default_cooldown          = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = data.aws_subnet_ids.subnet.ids
  security_groups           = concat([aws_security_group.bastion.id], var.additional_security_groups)
  iam_instance_profile_arn  = module.bastion.iam_instance_profile_arn

  # Launch template
  lt_name                = local.name
  description            = "Launch template of ${local.name}"
  update_default_version = true
  create_lt              = true
  image_id               = data.aws_ami.bastion_ami.image_id
  instance_type          = var.instance_type
  ebs_optimized          = var.ebs_optimized
  enable_monitoring      = true
  user_data_base64       = base64encode(local.user_data)

  use_mixed_instances_policy = true
  mixed_instances_policy = {
    instances_distribution = var.mixed_instances_distribution
    override               = var.launch_template_overrides
  }

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 8
        volume_type           = "gp3"
      }
    },
  ]

  tag_specifications = [
    {
      resource_type = "instance"
      tags          = { Type = "Instance" }
    },
    {
      resource_type = "volume"
      tags          = { Type = "Volume" }
    },
  ]

  tags = concat([
    {
      key                 = "Environment"
      value               = var.environment
      propagate_at_launch = true
    },
    {
      key                 = "Product"
      value               = var.product
      propagate_at_launch = true
    },
    {
      key                 = "Service"
      value               = local.name
      propagate_at_launch = true
    },
    {
      key                 = "Role"
      value               = var.service_role
      propagate_at_launch = true
    },
  ], var.additional_asg_tags)
}

# Instance Role
module "bastion" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 4.0"

  create_role             = true
  create_instance_profile = true
  force_detach_policies   = true
  role_name               = "BastionInstanceProfile"
  role_path               = "/service/ec2/"
  role_requires_mfa       = false
  role_description        = "Service role for RDS Enhanced Monitoring"

  trusted_role_services = [
    "ec2.amazonaws.com"
  ]
}


resource "aws_iam_role_policy" "policy_dynamodb_access" {
  name   = "DynamoDBAccess"
  role   = module.bastion.iam_role_name
  policy = data.aws_iam_policy_document.dynamodb_access.json
}

# Security Groups
resource "aws_security_group" "bastion" {
  name        = local.name
  vpc_id      = var.vpc_id
  description = "${local.name} security group"

  tags = {
    Description = "Security group for ${local.name}"
  }
}

resource "aws_security_group" "postgres" {
  name        = "${local.name}-postgres"
  vpc_id      = var.vpc_id
  description = "${local.name}-postgres security group"

  tags = {
    Description = "Security group for ${local.name}-postgres"
  }
}

resource "aws_security_group" "mongod" {
  name        = "${local.name}-mongod"
  vpc_id      = var.vpc_id
  description = "${local.name}-mongod security group"

  tags = {
    Description = "Security group for ${local.name}-mongod"
  }
}

resource "aws_security_group" "mysql" {
  name        = "${local.name}-mysql"
  vpc_id      = var.vpc_id
  description = "${local.name}-mysql security group"

  tags = {
    Description = "Security group for ${local.name}-mysql"
  }
}

resource "aws_security_group" "memcached" {
  name        = "${local.name}-memcached"
  vpc_id      = var.vpc_id
  description = "${local.name}-memcached security group"

  tags = {
    Description = "Security group for ${local.name}-memcached"
  }
}

resource "aws_security_group" "redis" {
  name        = "${local.name}-redis"
  vpc_id      = var.vpc_id
  description = "${local.name}-redis security group"

  tags = {
    Description = "Security group for ${local.name}-redis"
  }
}

resource "aws_security_group" "elasticsearch" {
  name        = "${local.name}-elasticsearch"
  vpc_id      = var.vpc_id
  description = "${local.name}-elasticsearch security group"

  tags = {
    Description = "Security group for ${local.name}-elasticsearch"
  }
}

# Security Group Rules
resource "aws_security_group_rule" "bastion_https_all" {
  type              = "egress"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  security_group_id = aws_security_group.bastion.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Egress from ${local.name} to all in 443"
}

resource "aws_security_group_rule" "bastion_http_all" {
  type              = "egress"
  from_port         = "80"
  to_port           = "80"
  protocol          = "tcp"
  security_group_id = aws_security_group.bastion.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Egress from ${local.name} to all in 80"
}

resource "aws_security_group_rule" "bastion_ssh_all" {
  type              = "egress"
  from_port         = "22"
  to_port           = "22"
  protocol          = "tcp"
  security_group_id = aws_security_group.bastion.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Egress from ${local.name} to all in 22"
}

resource "aws_security_group_rule" "egress_from_bastion_to_postgres_5432" {
  type                     = "egress"
  from_port                = "5432"
  to_port                  = "5432"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.bastion.id
  source_security_group_id = aws_security_group.postgres.id
  description              = "Egress from ${local.name} to ${local.name}-postgres in 5432"
}

resource "aws_security_group_rule" "egress_from_bastion_to_mongod_27017" {
  type                     = "egress"
  from_port                = "27017"
  to_port                  = "27017"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.bastion.id
  source_security_group_id = aws_security_group.mongod.id
  description              = "Egress from ${local.name} to ${local.name}-mongod in 27017"
}

resource "aws_security_group_rule" "ingress_from_bastion_to_postgres_5432" {
  type                     = "ingress"
  from_port                = "5432"
  to_port                  = "5432"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.postgres.id
  source_security_group_id = aws_security_group.bastion.id
  description              = "Ingress from ${local.name} to ${local.name}-postgres in 5432"
}

resource "aws_security_group_rule" "ingress_from_bastion_to_mongod_27017" {
  type                     = "ingress"
  from_port                = "27017"
  to_port                  = "27017"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.mongod.id
  source_security_group_id = aws_security_group.bastion.id
  description              = "Ingress from ${local.name} to ${local.name}-mongod in 27017"
}

resource "aws_security_group_rule" "egress_from_bastion_to_mysql_3306" {
  type                     = "egress"
  from_port                = "3306"
  to_port                  = "3306"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.bastion.id
  source_security_group_id = aws_security_group.mysql.id
  description              = "Egress from ${local.name} to ${local.name}-mysql in 3306"
}

resource "aws_security_group_rule" "ingress_from_bastion_to_mysql_3306" {
  type                     = "ingress"
  from_port                = "3306"
  to_port                  = "3306"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.mysql.id
  source_security_group_id = aws_security_group.bastion.id
  description              = "Ingress from ${local.name} to ${local.name}-mysql in 3306"
}

resource "aws_security_group_rule" "egress_from_bastion_to_memcached_11211" {
  type                     = "egress"
  from_port                = "11211"
  to_port                  = "11211"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.bastion.id
  source_security_group_id = aws_security_group.memcached.id
  description              = "Egress from ${local.name} to ${local.name}-memcached in 11211"
}

resource "aws_security_group_rule" "ingress_from_bastion_to_memcached_11211" {
  type                     = "ingress"
  from_port                = "11211"
  to_port                  = "11211"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.memcached.id
  source_security_group_id = aws_security_group.bastion.id
  description              = "Ingress from ${local.name} to ${local.name}-memcached in 11211"
}

resource "aws_security_group_rule" "egress_from_bastion_to_redis_6379" {
  type                     = "egress"
  from_port                = "6379"
  to_port                  = "6379"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.bastion.id
  source_security_group_id = aws_security_group.redis.id
  description              = "Egress from ${local.name} to ${local.name}-redis in 6379"
}

resource "aws_security_group_rule" "ingress_from_bastion_to_redis_6379" {
  type                     = "ingress"
  from_port                = "6379"
  to_port                  = "6379"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.redis.id
  source_security_group_id = aws_security_group.bastion.id
  description              = "Ingress from ${local.name} to ${local.name}-redis in 6379"
}

resource "aws_security_group_rule" "egress_from_bastion_to_elasticsearch_443" {
  type                     = "egress"
  from_port                = "443"
  to_port                  = "443"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.bastion.id
  source_security_group_id = aws_security_group.elasticsearch.id
  description              = "Egress from ${local.name} to ${local.name}-elasticsearch in 443"
}

resource "aws_security_group_rule" "ingress_from_bastion_to_elasticsearch_443" {
  type                     = "ingress"
  from_port                = "443"
  to_port                  = "443"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.elasticsearch.id
  source_security_group_id = aws_security_group.bastion.id
  description              = "Ingress from ${local.name} to ${local.name}-elasticsearch in 443"
}

