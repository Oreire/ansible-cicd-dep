provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "DevOpsEC2"
  }

  key_name      = var.key_name
  associate_public_ip_address = true

  provisioner "local-exec" {
    command = "echo ${self.public_ip} > ../ansible/hosts.txt"
  }
}
# resource "aws_security_group" "web_sg" {
#   name        = "web_sg"
#   description = "Allow HTTP and SSH traffic"

#     ingress {
#       from_port   = 22
#       to_port     = 22
#       protocol    = "tcp"
#       cidr_blocks = ["YOUR_TRUSTED_IP/32"]
#     }
#   }