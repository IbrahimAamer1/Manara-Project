# --- Database Module Outputs --- #

output "db_instance_address" {
  description = "The address of the RDS instance."
  value       = var.create_database ? aws_db_instance.main[0].address : null
}

output "db_instance_endpoint" {
  description = "The endpoint of the RDS instance."
  value       = var.create_database ? aws_db_instance.main[0].endpoint : null
}

output "db_instance_port" {
  description = "The port the DB instance is listening on."
  value       = var.create_database ? aws_db_instance.main[0].port : null
}

output "db_instance_name" {
  description = "The name of the RDS database."
  value       = var.create_database ? aws_db_instance.main[0].db_name : null
}

output "db_subnet_group_name" {
  description = "The name of the DB subnet group."
  value       = var.create_database ? aws_db_subnet_group.main[0].name : null
}

