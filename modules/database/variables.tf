# --- Database Module Variables --- #

variable "project_name" {
  description = "The name of the project, used for naming resources."
  type        = string
}

variable "create_database" {
  description = "Whether to create the database resources."
  type        = bool
  default     = true
}

variable "private_db_subnet_ids" {
  description = "List of private subnet IDs for the RDS instance."
  type        = list(string)
  default     = []
}

variable "rds_security_group_id" {
  description = "The ID of the security group for the RDS instance."
  type        = string
  default     = ""
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
  default     = "8.0" # Example for MySQL 8.0, adjust as needed
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
  description = "The master username for the database."
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "The master password for the database."
  type        = string
  sensitive   = true
}

variable "common_tags" {
  description = "Common tags to apply to all resources."
  type        = map(string)
  default     = {}
}

