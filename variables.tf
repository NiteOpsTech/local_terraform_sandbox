variable "aws_region" {
  type        = string
  description = "The target AWS geographic deployment region"
  default     = "us-east-1"
}

variable "sandbox_instance_type" {
  type        = string
  description = "The hardware performance tier for the test node"
  default     = "t3.micro" # Keeps it well within the free-tier compute budget
}