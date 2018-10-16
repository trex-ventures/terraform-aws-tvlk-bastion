output "instance_id" {
  description = "instance_id for bastion hosts"
  value       = "${aws_instance.this.id}"
}

output "instance_role_name" {
  description = "role name for the instances."
  value       = "${module.instance_profile.role_name}"
}
