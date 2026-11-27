variable "scaling_adjustment" {
  type    = number
  default = 1
}

variable "adjustment_type" {
  type    = string
  default = "ChangeInCapacity"
}

variable "cooldown" {
  type    = number
  default = 300
}

variable "comparison_operator" {
  type    = string
  default = "GreaterThanOrEqualToThreshold"
}

variable "evaluation_periods" {
  type    = number
  default = 2
}

variable "metric_name" {
  type    = string
  default = "CPUUtilization"
}

variable "period" {
  type    = number
  default = 300
}

variable "statistic" {
  type    = string
  default = "Average"
}

variable "threshold" {
  type    = number
  default = 80
}

variable "autoscaling_group_name" {
  type = string
}
