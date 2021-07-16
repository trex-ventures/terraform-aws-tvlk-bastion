output "asg_bastion_name" {
  description = "The name of the auto scaling group for bastion"
  value       = module.aws-autoscaling_bastion_asg.autoscaling_group_name
}

output "asg_launch_template_id" {
  value = module.aws-autoscaling_bastion_asg.launch_template_id
}

output "asg_launch_template_latest_version" {
  value = module.aws-autoscaling_bastion_asg.launch_template_latest_version
}

output "asg_user_data" {
  value = local.user_data
}
output "sg_bastion_id" {
  description = "id of security group for bastion instance."
  value       = aws_security_group.bastion.id
}

output "shared_sg_postgres_id" {
  description = "id of shared security group for postgres."
  value       = aws_security_group.postgres.id
}

output "shared_sg_mongod_id" {
  description = "id of shared security group for mongod."
  value       = aws_security_group.mongod.id
}

output "shared_sg_mysql_id" {
  description = "id of shared security group for mysql."
  value       = aws_security_group.mysql.id
}

output "shared_sg_memcached_id" {
  description = "id of shared security group for memcached."
  value       = aws_security_group.memcached.id
}

output "shared_sg_redis_id" {
  description = "id of shared security group for redis."
  value       = aws_security_group.redis.id
}

output "shared_sg_elasticsearch_id" {
  description = "id of shared security group for elasticsearch."
  value       = aws_security_group.elasticsearch.id
}

output "iam_role_name" {
  description = "role name for the instances."
  value       = module.bastion.iam_role_name
}

output "instance_profile_name" {
  description = "role name for the instance role."
  value       = module.bastion.iam_instance_profile_name
}

output "iam_role_arn" {
  description = "role name for the instances."
  value       = module.bastion.iam_role_arn
}
