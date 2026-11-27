variable "petclinic_alb_name" {
  type = string
  default = "petclinic-alb"
}

variable "load_balancer_type" {
  type = string
  default = "application"
}


variable "alb_listener_port" {
  type = number
  default = 80
}

variable "alb_listener_protocol" {
  type = string
  default = "HTTP"
}

variable "alb_target_group_name" {
  type = string
  default = "petclinic-alb-target-group"
}

variable "alb_target_group_port" {
  type = number
  default = 8080
}

variable "alb_target_group_protocol" {
  type = string
  default = "HTTP"
}

variable "alb_health_check_path" {
  type = string
  default = "/"
}

variable "alb_health_check_interval" {
  type = number
  default = 30
}

variable "alb_health_check_timeout" {
  type = number
  default = 5
}

variable "alb_health_check_healthy_threshold" {
  type = number
  default = 2
}

variable "alb_health_check_unhealthy_threshold" {
  type = number
  default = 2
}

variable "alb_health_check_matcher" {
  type = string
  default = "200"
}

variable "alb_listener_rule_priority" {
  type = number
  default = 100
}

variable "alb_listener_rule_path_pattern" {
  type = string
  default = "/petclinic/*"
}

variable "subnet_ids"
  type = list(string)
}

variable "petclinic_Sg"
  type = string
}
