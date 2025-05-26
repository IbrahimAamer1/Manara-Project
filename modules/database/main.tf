# --- Database Module (Optional) --- #

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  count      = var.create_database ? 1 : 0
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_db_subnet_ids

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-db-subnet-group"
    }
  )
}

# RDS Database Instance
resource "aws_db_instance" "main" {
  count                  = var.create_database ? 1 : 0
  identifier             = "${var.project_name}-db"
  allocated_storage      = var.db_allocated_storage 
  engine                 = var.db_engine            
  engine_version         = var.db_engine_version  
  instance_class         = var.db_instance_class   
  db_name                = var.db_name              
  username               = var.db_username          # Customizable: Master username
  password               = var.db_password         
  db_subnet_group_name   = aws_db_subnet_group.main[0].name
  vpc_security_group_ids = [var.rds_security_group_id]
  multi_az               = true                     
  skip_final_snapshot    = true                      final snapshot on deletion
  publicly_accessible    = false

  # Backup and Maintenance
  backup_retention_period = 7 # Customizable: Adjust backup retention days
  backup_window           = "03:00-04:00" # Customizable
  maintenance_window      = "sun:05:00-sun:06:00" 

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-db-instance"
    }
  )
}

