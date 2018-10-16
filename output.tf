output "instance_id" {
  description = "instance_id for bastion hosts"
  value       = "${aws_instance.this.id}"
}
