
output "instance_public_ip" {
  description = "Public IP of the deployed EC2 instance"
  value       = aws_instance.web.public_ip
}
output "instance_id" {
  description = "ID of the deployed EC2 instance"
  value       = aws_instance.web.id
}
output "security_group_id" {
  description = "ID of the security group for the EC2 instance"
  value       = aws_security_group.ansible_sg2.id
}
