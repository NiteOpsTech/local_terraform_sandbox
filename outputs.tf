output "sandbox_vpc_id" {
  value       = aws_vpc.sandbox_vpc.id
  description = "VPC ID for the lab boundary."
}

output "sandbox_subnet_id" {
  value       = aws_subnet.sandbox_subnet.id
  description = "Subnet ID for the detection subnet."
}

output "security_group_id" {
  value       = aws_security_group.sandbox_sg.id
  description = "Security group ID for the sandbox firewall."
}

output "target_host_private_ip" {
  value       = aws_instance.detection_host.private_ip
  description = "Private IP assigned to the lab target host."
}
