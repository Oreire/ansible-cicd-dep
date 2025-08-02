provider "aws" {
  region = var.aws_region
}


resource "null_resource" "prepare_ansible_dir" {
  provisioner "local-exec" {
    command = "mkdir -p ../ansible"
  }
}

resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  associate_public_ip_address = true
  provisioner "local-exec" {
  command = "mkdir -p ../ansible && echo ${self.public_ip} > ../ansible/hosts.txt"
}
tags = {
    Name        = "ansible-web-server"
    Environment = "Dev"
  }
  depends_on = [null_resource.prepare_ansible_dir]
}

resource "aws_security_group" "ansible_sg2" {
  name        = "ansible_sg"
  description = "Allow controlled HTTP and SSH access"

  ingress {
    description = "SSH access for trusted admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.0.2.0/32"] # Reserved for documentation/example; use real admin IP in production
  }

  ingress {
    description = "HTTP access from trusted subnet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["192.168.1.0/24"] # Replace with real public-facing CIDR if needed
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "ansible_sg2"
    Environment = "Dev"
  }
}
