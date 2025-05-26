# --- Monitoring Module --- #

# SNS Topic for CloudWatch Alarm Notifications
resource "aws_sns_topic" "alarms" {
  name = "${var.project_name}-alarms-topic"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-alarms-topic"
    }
  )
}

# Optional: SNS Topic Subscription (e.g., email)
# resource "aws_sns_topic_subscription" "email_target" {
#   topic_arn = aws_sns_topic.alarms.arn
#   protocol  = "email"
#   endpoint  = var.alarm_email 

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric",
        x      = 0,
        y      = 0,
        width  = 12,
        height = 6,
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix],
            [".", "HTTPCode_Target_5XX_Count", ".", "."],
            [".", "HTTPCode_ELB_5XX_Count", ".", "."],
            [".", "UnHealthyHostCount", ".", "."],
            [".", "HealthyHostCount", ".", "."]
          ],
          period = 300,
          stat   = "Sum",
          region = var.aws_region,
          title  = "ALB Metrics"
        }
      },
      {
        type   = "metric",
        x      = 0,
        y      = 6,
        width  = 12,
        height = 6,
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.asg_name]
          ],
          period = 300,
          stat   = "Average",
          region = var.aws_region,
          title  = "ASG Average CPU Utilization"
        }
      },
      # Customizable: Add more widgets for RDS metrics if var.create_database is true
      # Example RDS Widget (Uncomment and adjust if using RDS):
      # {
      #   type   = "metric",
      #   x      = 12,
      #   y      = 0,
      #   width  = 12,
      #   height = 6,
      #   properties = {
      #     metrics = [
      #       [ "AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.db_instance_identifier ],
      #       [ ".", "DatabaseConnections", ".", "." ],
      #       [ ".", "ReadIOPS", ".", "." ],
      #       [ ".", "WriteIOPS", ".", "." ]
      #     ],
      #     period = 300,
      #     stat = "Average",
      #     region = var.aws_region,
      #     title = "RDS Metrics"
      #   }
      # }
    ]
  })
}

# CloudWatch Alarm for High CPU Utilization on ASG
resource "aws_cloudwatch_metric_alarm" "asg_high_cpu" {
  alarm_name          = "${var.project_name}-asg-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300 # 5 minutes
  statistic           = "Average"
  threshold           = 80 # Customizable: Adjust CPU threshold percentage
  alarm_description   = "Alarm when ASG CPU exceeds 80%"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }
}

# CloudWatch Alarm for ALB 5XX Errors
resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  alarm_name          = "${var.project_name}-alb-5xx-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300 # 5 minutes
  statistic           = "Sum"
  threshold           = 10 # Customizable: Adjust threshold for 5XX errors
  alarm_description   = "Alarm when ALB 5XX errors exceed 10 in 5 minutes"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }
}

# Customizable: Add more alarms as needed (e.g., low healthy hosts, RDS high CPU/connections)

