# --- Compute Module Variables --- #

variable "project_name" {
  description = "The name of the project, used for naming resources."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where compute resources will be created."
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB."
  type        = list(string)
}

variable "private_app_subnet_ids" {
  description = "List of private application subnet IDs for the ASG."
  type        = list(string)
}

variable "ec2_security_group_id" {
  description = "The ID of the security group for EC2 instances."
  type        = string
}

variable "alb_security_group_id" {
  description = "The ID of the security group for the ALB."
  type        = string
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instances."
  type        = string
  # Example: Use data source in root module to get latest Amazon Linux 2 AMI
}

variable "instance_type" {
  description = "The instance type for the EC2 instances."
  type        = string
  default     = "t3.micro" # Customizable
}

variable "key_name" {
  description = "The name of the EC2 key pair for SSH access."
  type        = string
  # Ensure this key pair exists in the target region
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

variable "common_tags" {
  description = "Common tags to apply to all resources."
  type        = map(string)
  default     = {}
}

