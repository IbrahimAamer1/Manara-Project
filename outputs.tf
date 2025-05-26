# --- Root Module Outputs --- #

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer."
  value       = module.compute.alb_dns_name
}

output "vpc_id" {
  description = "The ID of the created VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of IDs of the public subnets."
  value       = module.vpc.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "List of IDs of the private application subnets."
  value       = module.vpc.private_app_subnet_ids
}

output "db_instance_address" {
  description = "The address of the RDS instance (if created)."
  value       = module.database.db_instance_address
}

output "db_instance_endpoint" {
  description = "The endpoint of the RDS instance (if created)."
  value       = module.database.db_instance_endpoint
}

output "cloudwatch_dashboard_name" {
  description = "The name of the CloudWatch dashboard."
  value       = module.monitoring.cloudwatch_dashboard_name
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic for alarms."
  value       = module.monitoring.sns_topic_arn
}

