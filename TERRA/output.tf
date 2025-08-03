
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
output "subnet_vpc" {
  value = aws_subnet.public.vpc_id
}

output "sg_vpc" {
  value = aws_security_group.ansible_sg2.vpc_id
}
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}