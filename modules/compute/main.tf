# --- Compute Module --- #

# IAM Role for EC2 Instances
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-ec2-role"
    }
  )
}

# Attach necessary policies to the EC2 role
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Create IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-ec2-profile"
    }
  )
}

# Launch Template for EC2 Instances
resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-lt-"
  description   = "Launch template for the web application"
  image_id      = var.ami_id # Customizable: Specify the desired AMI ID (e.g., latest Amazon Linux 2)
  instance_type = var.instance_type 

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  key_name = var.key_name # Customizable: Specify your EC2 key pair name

  network_interfaces {
    associate_public_ip_address = false # Instances are in private subnets
    security_groups             = [var.ec2_security_group_id]
  }

  # User data script to install and configure the web server
  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello from $(hostname -f) - Managed by Terraform</h1>" > /var/www/html/index.html
    # Customizable: Add commands to deploy your specific application code here
    EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.common_tags,
      {
        Name = "${var.project_name}-instance"
      }
    )
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-launch-template"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Application Load Balancer (ALB)
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids # ALB needs to be in public subnets

  enable_deletion_protection = false 

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-alb"
    }
  )
}

# Target Group for ALB
resource "aws_lb_target_group" "app" {
  name        = "${var.project_name}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    interval            = 30
    path                = "/" 
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-target-group"
    }
  )
}

# Listener for ALB (HTTP)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }

  # Customizable: Add HTTPS listener configuration if needed (requires ACM certificate)
  # lifecycle {
  #   create_before_destroy = true
  # }
}

# Auto Scaling Group (ASG)
resource "aws_autoscaling_group" "app" {
  name_prefix = "${var.project_name}-asg-"
  vpc_zone_identifier = var.private_app_subnet_ids # ASG instances in private subnets

  desired_capacity = var.asg_desired_capacity # Customizable
  min_size         = var.asg_min_size         # Customizable
  max_size         = var.asg_max_size         # Customizable

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app.arn]

  health_check_type         = "ELB"
  health_check_grace_period = 300 # Customizable: Adjust grace period based on instance startup time

  # Ensure instances are replaced if they fail health checks
  force_delete = true

  # Scaling Policies
  # Customizable: Add more sophisticated scaling policies if needed

  tag {
    key                 = "Name"
    value               = "${var.project_name}-asg-instance"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Optional: Target Tracking Scaling Policy based on CPU Utilization
resource "aws_autoscaling_policy" "cpu_scaling" {
  name                   = "${var.project_name}-cpu-scaling-policy"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.cpu_target_value 
  }
}

