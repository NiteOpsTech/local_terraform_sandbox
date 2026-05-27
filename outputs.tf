output "sandbox_vpc_id" {
  value       = aws_vpc.sandbox_vpc.id
  description = "The unique tracking reference identifier for the virtual cloud boundary"
}

output "target_host_public_ip" {
  value       = aws_instance.detection_host.public_ip
  description = "The dynamic routing address assigned to our attack simulation node"
}
