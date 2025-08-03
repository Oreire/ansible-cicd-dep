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
  vpc_security_group_ids = [aws_security_group.ansible_sg2.id]
  subnet_id              = aws_subnet.main.id
  provisioner "local-exec" {
  command = "mkdir -p ../ansible && echo ${self.public_ip} > ../ansible/hosts.txt"
}
tags = {
    Name        = "DevOpsEC2"
    Environment = "Staging"
    Owner      = "ayomide"
  }
  depends_on = [null_resource.prepare_ansible_dir]
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  
  tags = {
    Name        = "MainVPC"
    Environment = "Dev"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "main-igw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-2a"
  tags = {
    Name = "main-public-subnet"
  }
}


resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
 
resource "aws_security_group" "ansible_sg2" {
  name        = "ansible_sg2"
  description = "Allow controlled HTTP and SSH access"

  ingress {
    description = "SSH access for trusted admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["203.0.113.14/32"]  # Reserved for documentation/example; use real admin IP in production
  }

  ingress {
    description = "HTTP access from trusted subnet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Replace with real public-facing CIDR if needed
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
