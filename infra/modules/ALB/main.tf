locals {
  https_enabled = var.certificate_arn != null
}

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
    type             = local.https_enabled ? "redirect" : "forward"
    target_group_arn = local.https_enabled ? null : aws_lb_target_group.petclinic_alb_target_group.arn

    dynamic "redirect" {
      for_each = local.https_enabled ? [true] : []

      content {
        port        = tostring(aws_lb_listener.petclinic_https_listener[0].port)
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }
}

resource "aws_lb_listener" "petclinic_https_listener" {
  count = local.https_enabled ? 1 : 0

  load_balancer_arn = aws_lb.petclinic_alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"

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
  listener_arn = local.https_enabled ? aws_lb_listener.petclinic_https_listener[0].arn : aws_lb_listener.petclinic_alb_listener.arn
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
