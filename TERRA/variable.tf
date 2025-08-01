variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "eu-west-2"
}

variable "ami_id" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
  default     = "ami-044415bb13eee2391" # Use the most accurate or latest AMI here
}

variable "instance_type" {
  description = "The EC2 instance type to deploy"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "SSH key pair name used for EC2 access"
  type        = string
  default     = "maven_key" # Consistency with your Ansible key config
}

