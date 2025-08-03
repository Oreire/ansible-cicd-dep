# ansible-cicd-dep
Infrastructure Automation for EC2 Provisioning and Dockerized Application Deployment Using Terraform, Docker-Compose, Ansible, and AWS Dynamic Inventory


name: Infrastructure Automation and Deployment

on:
  push:
    branches: [ main ]

jobs:
  provision-deploy:
    runs-on: ubuntu-latest

    env:
      AWS_REGION: eu-west-2
      TF_WORKING_DIR: ./TERRA
      ANSIBLE_DIR: ./ANSIB

    steps:
    - name: ✅ Checkout repo
      uses: actions/checkout@v3

    - name: 🔐 Configure AWS Credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ env.AWS_REGION }}

    - name: 🔧 Setup Terraform CLI
      uses: hashicorp/setup-terraform@v2

    - name: 📂 Terraform Initialisation
      run: terraform init
      working-directory: ${{ env.TF_WORKING_DIR }}


    - name: 🧹 Terraform Format Check
      run: terraform fmt 
      working-directory: ${{ env.TF_WORKING_DIR }}

    - name: 🔍 Terraform Validate
      run: terraform validate
      working-directory: ${{ env.TF_WORKING_DIR }}

    - name: 📊 Terraform Plan
      run: terraform plan
      working-directory: ${{ env.TF_WORKING_DIR }}

    - name: 🚀 Terraform Apply
      run: terraform apply -auto-approve
      working-directory: ${{ env.TF_WORKING_DIR }}

    - name: 📦 Capture Terraform Outputs
      run: terraform output -json
      working-directory: ${{ env.TF_WORKING_DIR }}

    
    - name: 🔑 Inject SSH Key
      run: |
        mkdir -p ~/.ssh
        echo "$SSH_KEY" > ~/.ssh/id_rsa
        chmod 600 ~/.ssh/id_rsa
      env:
        SSH_KEY: ${{ secrets.AWS_EC2_PRIVATE_KEY }}


    # - name: 🐍 Install Python, Ansible & Collections
    #   run: |
    #     pip install ansible
    #     ansible-galaxy collection install ansible.utils
    #     ansible-galaxy collection list | grep ansible.utils || {
    #       echo "❌ Collection ansible.utils not found after install."
    #       exit 1
    #     }
    - name: 🐍 Install Ansible & Required Collections
      run: |
        pip install --user ansible
        export PATH=$HOME/.local/bin:$PATH
        ansible-galaxy collection install ansible.utils
        ansible-galaxy collection list | grep ansible.utils || {
          echo "❌ Collection ansible.utils not found after install."
          exit 1
        }
    - name: ⚙️ Create ansible.cfg
      run: |
        echo "[defaults]" > ansible.cfg
        echo "inventory = aws_ec2.yaml" >> ansible.cfg
        echo "host_key_checking = False" >> ansible.cfg

    - name: 📂 Run Ansible Playbook with Dynamic Inventory
      working-directory: ${{ env.ANSIBLE_DIR }}
      run: |
        echo "Running Ansible Playbook..."
        ansible-playbook -i aws_ec2.yaml playbook.yaml
      shell: /usr/bin/bash -e {0}
      env:
        AWS_REGION: ${{ env.AWS_REGION }}
        AWS_DEFAULT_REGION: ${{ env.AWS_REGION }}
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        TF_WORKING_DIR: ${{ env.TF_WORKING_DIR }}
        ANSIBLE_DIR: ${{ env.ANSIBLE_DIR }}


Main.tf

# ✅ VPC Definition
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name        = "cicd-vpc"
    Environment = "Dev"
  }
}

# ✅ Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "cicd-igw"
  }
}

# ✅ Public Subnet with IGW Route
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-2a"
  tags = {
    Name = "cicd-public-subnet"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "cicd-public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ✅ SSH Security Group (CI-safe)
resource "aws_security_group" "ssh" {
  name        = "cicd-ssh-sg"
  vpc_id      = aws_vpc.main.id
  description = "Allow SSH and HTTP access"

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "cicd-sg"
    Environment = "Dev"
  }
}

# ✅ EC2 Instance with Tag for Ansible
resource "aws_instance" "web" {
  ami                    = "ami-08e2c1fc282d7f130"  # Ubuntu 22.04 LTS (eu-west-2)
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  associate_public_ip_address = true
  key_name               = "your-keypair-name"  # Update this
  vpc_security_group_ids = [aws_security_group.ssh.id]

  tags = {
    Name        = "DevOpsEC2"
    Environment = "Dev"
    Provisioned = "Terraform"
  }
}

aws_ec2.yaml

plugin: aws_ec2
regions:
  - eu-west-2
filters:
  tag:Name: DevOpsEC2
hostnames:
  - public-ip-address
keyed_groups:
  - key: tags.Name
