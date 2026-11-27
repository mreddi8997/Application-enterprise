resource "aws_autoscaling_policy" "main" {
  name                   = "${var.autoscaling_group_name}-cpu-scale-out"
  policy_type            = "SimpleScaling"
  scaling_adjustment     = var.scaling_adjustment
  adjustment_type        = var.adjustment_type
  cooldown               = var.cooldown
  autoscaling_group_name = var.autoscaling_group_name
}

resource "aws_cloudwatch_metric_alarm" "main" {
  alarm_name          = "${var.autoscaling_group_name}-high-cpu"
  comparison_operator = var.comparison_operator
  evaluation_periods  = var.evaluation_periods
  metric_name         = var.metric_name
  namespace           = "AWS/EC2"
  period              = var.period
  statistic           = var.statistic
  threshold           = var.threshold

  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.main.arn]
}
