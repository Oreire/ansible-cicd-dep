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
    command = "echo ${self.public_ip} > ../ansible/hosts.txt"
  }

  depends_on = [null_resource.prepare_ansible_dir]
}

resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow HTTP and SSH traffic"
  #vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_TRUSTED_IP/32"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["192.168.1.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #tags = var.tags
}
