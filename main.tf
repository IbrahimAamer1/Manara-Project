
# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Data source for Availability Zones
data "aws_availability_zones" "available" {}

# Data source for latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  project_name             = var.project_name
  aws_region               = var.aws_region
  vpc_cidr                 = var.vpc_cidr
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
  create_database          = var.create_database
  common_tags              = var.common_tags
}

# Security Module
module "security" {
  source = "./modules/security"

  project_name       = var.project_name
  vpc_id             = module.vpc.vpc_id
  allowed_ssh_cidr   = var.allowed_ssh_cidr
  create_database    = var.create_database
  db_port            = var.db_port
  common_tags        = var.common_tags
}

# Compute Module (ALB, ASG, Launch Template)
module "compute" {
  source = "./modules/compute"

  project_name            = var.project_name
  vpc_id                  = module.vpc.vpc_id
  public_subnet_ids       = module.vpc.public_subnet_ids
  private_app_subnet_ids  = module.vpc.private_app_subnet_ids
  ec2_security_group_id   = module.security.ec2_security_group_id
  alb_security_group_id   = module.security.alb_security_group_id
  ami_id                  = data.aws_ami.amazon_linux_2.id
  instance_type           = var.instance_type
  key_name                = var.key_name
  asg_desired_capacity    = var.asg_desired_capacity
  asg_min_size            = var.asg_min_size
  asg_max_size            = var.asg_max_size
  cpu_target_value        = var.cpu_target_value
  common_tags             = var.common_tags
}

# Database Module (Optional RDS)
module "database" {
  source = "./modules/database"

  project_name            = var.project_name
  create_database         = var.create_database
  private_db_subnet_ids   = module.vpc.private_db_subnet_ids
  rds_security_group_id   = module.security.rds_security_group_id
  db_allocated_storage    = var.db_allocated_storage
  db_engine               = var.db_engine
  db_engine_version       = var.db_engine_version
  db_instance_class       = var.db_instance_class
  db_name                 = var.db_name
  db_username             = var.db_username
  db_password             = var.db_password
  common_tags             = var.common_tags
}

# Monitoring Module (CloudWatch Dashboard, Alarms, SNS)
module "monitoring" {
  source = "./modules/monitoring"

  project_name           = var.project_name
  aws_region             = var.aws_region
  asg_name               = module.compute.asg_name
  alb_arn_suffix         = module.compute.alb_arn_suffix
  alarm_email            = var.alarm_email
  create_database        = var.create_database
  db_instance_identifier = var.create_database ? module.database.db_instance_name : null
  common_tags            = var.common_tags
}

