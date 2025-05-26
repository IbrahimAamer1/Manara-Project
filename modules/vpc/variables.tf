# --- VPC Module Variables --- #

variable "project_name" {
  description = "The name of the project, used for naming resources."
  type        = string
  default     = "webapp"
}

variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
}

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

variable "create_database" {
  description = "Whether to create resources for the database (subnets, etc.)."
  type        = bool
  default     = true # Set to false if not using RDS
}

variable "common_tags" {
  description = "Common tags to apply to all resources."
  type        = map(string)
  default     = {}
}

