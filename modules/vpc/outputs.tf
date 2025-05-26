# --- VPC Module Outputs --- #

output "vpc_id" {
  description = "The ID of the created VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of IDs of the public subnets."
  value       = aws_subnet.public[*].id
}

output "private_app_subnet_ids" {
  description = "List of IDs of the private application subnets."
  value       = aws_subnet.private_app[*].id
}

output "private_db_subnet_ids" {
  description = "List of IDs of the private database subnets."
  value       = var.create_database ? aws_subnet.private_db[*].id : []
}

output "nat_gateway_public_ips" {
  description = "List of public IPs of the NAT Gateways."
  value       = aws_eip.nat[*].public_ip
}

output "availability_zones" {
  description = "List of availability zones used."
  value       = data.aws_availability_zones.available.names
}

