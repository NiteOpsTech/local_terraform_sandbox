variable "aws_profile" {
  type        = string
  description = "Named AWS CLI profile Terraform should use."
  default     = "niteops-lab"
}

variable "aws_region" {
  type        = string
  description = "AWS region for the lab sandbox."
  default     = "us-east-1"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the sandbox VPC."
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  type        = string
  description = "CIDR block for the detection subnet."
  default     = "10.0.1.0/24"
}

variable "allowed_ssh_cidr" {
  type        = string
  description = "Optional trusted CIDR for SSH. Leave empty to create no inbound SSH rule."
  default     = ""
}

variable "sandbox_instance_type" {
  type        = string
  description = "EC2 instance type for the lab target host."
  default     = "t3.micro"
}
