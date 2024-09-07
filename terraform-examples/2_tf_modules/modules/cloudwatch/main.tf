#Create an AWS CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "EC2_Dashboard" {
  dashboard_name = "EC2-Dashboard"
  dashboard_body = <<EOF
{
    "widgets": [
        {
            "type": "explorer",
            "width": 24,
            "height": 15,
            "x": 0,
            "y": 0,
            "properties": {
                "metrics": [
                    {
                        "metricName": "CPUUtilization",
                        "resourceType": "AWS::EC2::Instance",
                        "stat": "Maximum"
                    }
                ],
                "aggregateBy": {
                    "key": "InstanceType",
                    "func": "MAX"
                },
                "labels": [
                    {
                        "key": "State",
                        "value": "running"
                    }
                ],
                "widgetOptions": {
                    "legend": {
                        "position": "bottom"
                    },
                    "view": "timeSeries",
                    "rowsPerPage": 8,
                    "widgetsPerRow": 2
                },
                "period": 60,
                "title": "Running EC2 Instances CPUUtilization"
            }
        }
    ]
}
EOF
}

#Create an AWS CloudWatch metric alarm
resource "aws_cloudwatch_metric_alarm" "EC2_CPU_Usage_Alarm" {
  alarm_name                = "EC2_CPU_Usage_Alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "70"
  alarm_description         = "This metric monitors ec2 cpu utilization exceeding 70%"
}

#Create an AWS CloudWatch Log Group
resource "aws_cloudwatch_log_group" "web_log_group" {
  name = "web_log_group"
  retention_in_days = 30
}

#Create an AWS CloudWatch log stream
resource "aws_cloudwatch_log_stream" "web_log_stream" {
  name           = "web_log_stream"
  log_group_name = aws_cloudwatch_log_group.web_log_group.name
}