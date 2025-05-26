# --- Security Module Outputs --- #

output "alb_security_group_id" {
  description = "The ID of the Application Load Balancer security group."
  value       = aws_security_group.alb.id
}

output "ec2_security_group_id" {
  description = "The ID of the EC2 instance security group."
  value       = aws_security_group.ec2.id
}

output "rds_security_group_id" {
  description = "The ID of the RDS security group (if created)."
  value       = var.create_database ? aws_security_group.rds[0].id : null
}

