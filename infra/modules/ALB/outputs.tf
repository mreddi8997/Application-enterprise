output "target_group_arn" {
  value      = aws_lb_target_group.petclinic_alb_target_group.arn
  depends_on = [aws_lb_listener.petclinic_alb_listener]
}

output "url" {
  value = "http://${aws_lb.petclinic_alb.dns_name}"
}
