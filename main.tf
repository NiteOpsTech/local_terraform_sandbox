# 1. Define the cloud service provider initialization rules
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# 2. Architect the Isolated Virtual Private Cloud (VPC)
resource "aws_vpc" "sandbox_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "NiteOpsTech-Security-Sandbox"
  }
}

# 3. Provision the Public Layer Subnet Routing Block
resource "aws_subnet" "sandbox_subnet" {
  vpc_id                  = aws_vpc.sandbox_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Sandbox-Detection-Subnet"
  }
}

# 4. Attach an Internet Gateway for Managed Egress Connections
resource "aws_internet_gateway" "sandbox_gw" {
  vpc_id = aws_vpc.sandbox_vpc.id

  tags = {
    Name = "Sandbox-Gateway"
  }
}

# 5. Build the Virtual Route Table Layer
resource "aws_route_table" "sandbox_rt" {
  vpc_id = aws_vpc.sandbox_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sandbox_gw.id
  }
}

resource "aws_route_table_association" "sandbox_rta" {
  subnet_id      = aws_subnet.sandbox_subnet.id
  route_table_id = aws_route_table.sandbox_rt.id
}

# 6. Engineer the Stateful Firewall (Security Group Rule Layer)
resource "aws_security_group" "sandbox_sg" {
  name        = "security-sandbox-firewall"
  description = "Enforces zero-trust restriction profiles for simulation testing"
  vpc_id      = aws_vpc.sandbox_vpc.id

  # Inbound Security Rules: ONLY allow SSH traffic from your specific host ip
  ingress {
    description = "Restricted Administrator Management Tunnel"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # In a production environment, swap this with your exact public IPv4 address!
  }

  # Outbound Security Rules: Allow out-of-band updates, block internal broadcast noise
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 7. Deploy the Ephemeral Detection Testing Compute Node (EC2)
resource "aws_instance" "detection_host" {
  ami                    = "ami-0c7217cdde317cfec" # Standard Ubuntu Server 22.04 LTS Long-Term Stable image
  instance_type          = var.sandbox_instance_type
  subnet_id              = aws_subnet.sandbox_subnet.id
  vpc_security_group_ids = [aws_security_group.sandbox_sg.id]

  tags = {
    Name = "NiteOpsTech-Target-Host"
  }
}