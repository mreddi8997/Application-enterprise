resource "aws_lb" "petclinic_alb" {
  name               = var.petclinic_alb_name
  internal           = false
  load_balancer_type = var.load_balancer_type
  security_groups    = [var.alb_security_group_id]
  subnets            = var.subnet_ids

  enable_deletion_protection = false
}

resource "aws_lb_listener" "petclinic_alb_listener" {
  load_balancer_arn = aws_lb.petclinic_alb.arn
  port              = var.alb_listener_port
  protocol          = var.alb_listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.petclinic_alb_target_group.arn
  }
}

resource "aws_lb_target_group" "petclinic_alb_target_group" {
  name     = var.alb_target_group_name
  port     = var.alb_target_group_port
  protocol = var.alb_target_group_protocol
  vpc_id   = var.vpc_id

  health_check {
    path                = var.alb_health_check_path
    interval            = var.alb_health_check_interval
    timeout             = var.alb_health_check_timeout
    healthy_threshold   = var.alb_health_check_healthy_threshold
    unhealthy_threshold = var.alb_health_check_unhealthy_threshold
    matcher             = var.alb_health_check_matcher
  }
}

resource "aws_lb_listener_rule" "petclinic_alb_listener_rule" {
  listener_arn = aws_lb_listener.petclinic_alb_listener.arn
  priority     = var.alb_listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.petclinic_alb_target_group.arn
  }

  condition {
    path_pattern {
      values = [var.alb_listener_rule_path_pattern]
    }
  }
}
