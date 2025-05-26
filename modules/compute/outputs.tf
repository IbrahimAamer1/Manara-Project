# --- Compute Module Outputs --- #

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer."
  value       = aws_lb.main.dns_name
}

output "alb_arn_suffix" {
  description = "The ARN suffix of the Application Load Balancer."
  value       = aws_lb.main.arn_suffix
}

output "asg_name" {
  description = "The name of the Auto Scaling Group."
  value       = aws_autoscaling_group.app.name
}

output "launch_template_id" {
  description = "The ID of the launch template."
  value       = aws_launch_template.app.id
}

