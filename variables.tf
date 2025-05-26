# --- Root Module Variables --- #

variable "project_name" {
  description = "The name of the project,."
  type        = string
  default     = "webapp-project"
}

variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1" # Customizable: Change to your preferred region
}

variable "common_tags" {
  description = "Common tags to apply to all resources."
  type        = map(string)
  default = {
    Project   = "ScalableWebApp"
    ManagedBy = "Terraform"
  }
}

# --- VPC Variables --- #
variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"] # Default for 2 AZs
}

variable "private_app_subnet_cidrs" {
  description = "List of CIDR blocks for private application subnets."
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"] # Default for 2 AZs
}

variable "private_db_subnet_cidrs" {
  description = "List of CIDR blocks for private database subnets."
  type        = list(string)
  default     = ["10.0.5.0/24", "10.0.6.0/24"] # Default for 2 AZs
}

# --- Security Variables --- #
variable "allowed_ssh_cidr" {
  description = "The CIDR block allowed for SSH access to EC2 instances."
  type        = string
  default     = "0.0.0.0/0" 
}

# --- Compute Variables --- #
variable "instance_type" {
  description = "The instance type for the EC2 instances."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "The name of the EC2 key pair for SSH access (must exist in the specified region)."
  type        = string
  # Example: default = "my-ec2-key"
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in the Auto Scaling Group."
  type        = number
  default     = 2
}

variable "asg_min_size" {
  description = "Minimum number of instances in the Auto Scaling Group."
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum number of instances in the Auto Scaling Group."
  type        = number
  default     = 4
}

variable "cpu_target_value" {
  description = "Target CPU utilization percentage for ASG scaling."
  type        = number
  default     = 70
}

# --- Database Variables --- #
variable "create_database" {
  description = "Set to true to create the RDS database, false to skip."
  type        = bool
  default     = true # Set to false if you don't need a database
}

variable "db_port" {
  description = "The port the database listens on."
  type        = number
  default     = 3306 # Default for MySQL. Change to 5432 for PostgreSQL if needed.
}

variable "db_allocated_storage" {
  description = "The allocated storage for the database in GB."
  type        = number
  default     = 20
}

variable "db_engine" {
  description = "The database engine to use (e.g., mysql, postgres)."
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "The version of the database engine."
  type        = string
  default     = "8.0.35" # Example for MySQL 8.0, check AWS for latest supported versions
}

variable "db_instance_class" {
  description = "The instance class for the RDS database."
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "The name of the initial database to create."
  type        = string
  default     = "webappdb"
}

variable "db_username" {
  description = "The master username for the database (required if create_database is true)."
  type        = string
  sensitive   = true
  default     = null # Must be provided if create_database is true
}

variable "db_password" {
  description = "The master password for the database (required if create_database is true)."
  type        = string
  sensitive   = true
  default     = null # Must be provided if create_database is true
}

# --- Monitoring Variables --- #
variable "alarm_email" {
  description = "Email address to subscribe to the SNS topic for alarms. Leave empty to disable email notifications."
  type        = string
  default     = "ibrahimaamer"@gmail.com"
}

