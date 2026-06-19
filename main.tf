terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
      Project     = "NiteOpsTech-Security-Sandbox"
      Environment = "lab"
      ManagedBy   = "terraform"
    }
  }
}

data "aws_ami" "ubuntu_lts" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_vpc" "sandbox_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "niteops-security-sandbox-vpc"
  }
}

resource "aws_subnet" "sandbox_subnet" {
  vpc_id                  = aws_vpc.sandbox_vpc.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = false

  tags = {
    Name = "niteops-detection-subnet"
  }
}

resource "aws_internet_gateway" "sandbox_gw" {
  vpc_id = aws_vpc.sandbox_vpc.id

  tags = {
    Name = "niteops-sandbox-gateway"
  }
}

resource "aws_route_table" "sandbox_rt" {
  vpc_id = aws_vpc.sandbox_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sandbox_gw.id
  }

  tags = {
    Name = "niteops-sandbox-route-table"
  }
}

resource "aws_route_table_association" "sandbox_rta" {
  subnet_id      = aws_subnet.sandbox_subnet.id
  route_table_id = aws_route_table.sandbox_rt.id
}

resource "aws_security_group" "sandbox_sg" {
  name        = "niteops-security-sandbox-firewall"
  description = "Lab firewall for the NiteOpsTech Terraform sandbox"
  vpc_id      = aws_vpc.sandbox_vpc.id

  dynamic "ingress" {
    for_each = var.allowed_ssh_cidr == "" ? [] : [var.allowed_ssh_cidr]

    content {
      description = "Restricted administrator SSH from approved CIDR"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  egress {
    description = "Allow outbound updates from lab resources"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "niteops-sandbox-security-group"
  }
}

resource "aws_instance" "detection_host" {
  ami                         = data.aws_ami.ubuntu_lts.id
  instance_type               = var.sandbox_instance_type
  subnet_id                   = aws_subnet.sandbox_subnet.id
  vpc_security_group_ids      = [aws_security_group.sandbox_sg.id]
  associate_public_ip_address = false

  tags = {
    Name = "niteops-target-host"
  }
}
