# --- Security Module Variables --- #

variable "project_name" {
  description = "The name of the project, used for naming resources."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where security groups will be created."
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "The CIDR block allowed for SSH access to EC2 instances."
  type        = string
  default     = "0.0.0.0/0" # WARNING: Allows SSH from anywhere. Restrict this in production.
}

variable "create_database" {
  description = "Whether to create resources for the database (RDS security group)."
  type        = bool
  default     = true
}

variable "db_port" {
  description = "The port the database listens on (used for RDS SG)."
  type        = number
  default     = 3306 # Default for MySQL. Change to 5432 for PostgreSQL if needed.
}

variable "common_tags" {
  description = "Common tags to apply to all resources."
  type        = map(string)
  default     = {}
}

