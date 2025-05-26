# --- Monitoring Module Variables --- #

variable "project_name" {
  description = "The name of the project, used for naming resources."
  type        = string
}

variable "aws_region" {
  description = "The AWS region where resources are deployed."
  type        = string
}

variable "asg_name" {
  description = "The name of the Auto Scaling Group to monitor."
  type        = string
}

variable "alb_arn_suffix" {
  description = "The ARN suffix of the Application Load Balancer to monitor."
  type        = string
  # Example: app/webapp-alb/abcdef1234567890
}

variable "alarm_email" {
  description = "Email address to subscribe to the SNS topic for alarms."
  type        = string
  default     = "" # Set an email address to enable email notifications
}

variable "create_database" {
  description = "Whether database resources were created (to potentially add DB widgets/alarms)."
  type        = bool
  default     = true
}

variable "db_instance_identifier" {
  description = "The identifier of the RDS DB instance (if created)."
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Common tags to apply to all resources."
  type        = map(string)
  default     = {}
}

