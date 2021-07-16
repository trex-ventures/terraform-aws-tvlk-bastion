variable "ebs_optimized" {
  description = "whether ec2 instance using ebs optimized or not"
  default     = "false"
  type        = string
}

variable "service_role" {
  description = "service role for the instance"
  type        = string
  default     = "bastion"
}

variable "vpc_id" {
  description = "vpc id where ec2 instances reside."
  type        = string
}

variable "subnet_tier" {
  description = "tier of subnet where bastion ec2 instance reside, we recommend to use the subnet with tier app, as it is private."
  type        = string
  default     = "app"
}

variable "ami_owner_account_id" {
  description = "aws account id who owns the golden bastion AMI owner."
  type        = string
  default     = "099720109477" #canonical - https://ubuntu.com/server/docs/cloud-images/amazon-ec2
}

variable "product" {
  description = "product domain who own this ec2 instances."
  type        = string
}

variable "instance_type" {
  description = "instance type for bastion hosts."
  default     = "t3.micro"
  type        = string
}

variable "volume_size" {
  description = "size for root volume instances."
  default     = 8
  type        = number
}

variable "volume_type" {
  description = "type of ebs volume for root volume instances."
  default     = "gp3"
  type        = string
}

variable "environment" {
  description = "environment for this resources."
  type        = string
}

variable "ami_name_prefix" {
  description = "prefix for ami filter"
  type        = string
  default     = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
}

variable "enable_detailed_monitoring" {
  description = "wheter to enable detailed monitoring for ec2 instances or not"
  default     = "false"
  type        = string
}

variable "asg_capacity" {
  description = "capacity of ec2 instances for autoscaling group"
  type        = number
}

variable "description" {
  description = "description for this cluster"
  type        = string
}

variable "asg_wait_for_capacity_timeout" {
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out"
  type        = string
  default     = "0m"
}

variable "asg_health_check_grace_period" {
  description = "Time, in seconds, to wait for new instances before checking their health"
  type        = string
  default     = "300"
}

variable "asg_default_cooldown" {
  description = "Time, in seconds, the minimum interval of two scaling activities"
  type        = string
  default     = "300"
}

variable "asg_health_check_type" {
  description = "healthchek type for autoscaling group"
  default     = "EC2"
  type        = string
}

variable "user_data" {
  type        = string
  default     = " "
  description = "The spawned instances will have this user data. Use the rendered value of a terraform's `template_cloudinit_config` data" // https://www.terraform.io/docs/providers/template/d/cloudinit_config.html#rendered
}

variable "additional_asg_tags" {
  type        = list(map(string))
  default     = []
  description = "The created ASG (and spawned instances) will have these tags, merged over the default"
}

variable "additional_security_groups" {
  type        = list(string)
  default     = []
  description = "Additional security group ids to be attached to the instance"
}

variable "launch_template_overrides" {
  type = list(map(string))

  default = [
    {
      "instance_type" = "t3a.micro"
    },
    {
      "instance_type" = "t3.micro"
    },
  ]

  description = <<EOT
  List of nested arguments provides the ability to specify multiple instance types. See https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html#override
  When using plain launch template, the first element's instance_type will be used as the launch template instance type.
  EOT
}

variable "mixed_instances_distribution" {
  type        = map(string)
  description = "Specify the distribution of on-demand instances and spot instances. See https://docs.aws.amazon.com/autoscaling/ec2/APIReference/API_InstancesDistribution.html"

  default = {
    on_demand_allocation_strategy            = "prioritized"
    on_demand_base_capacity                  = "0"
    on_demand_percentage_above_base_capacity = "0"
    spot_allocation_strategy                 = "lowest-price"
    spot_instance_pools                      = "2"
    spot_max_price                           = ""
  }
}

variable "tag_specifications" {
  type = list(object({
    resource_type = string
    tags          = map(string)
  }))
  default = [
    {
      resource_type = "instance"
      tags          = { Type = "Instance" }
    },
    {
      resource_type = "volume"
      tags          = { Type = "Volume" }
    },
  ]
}
