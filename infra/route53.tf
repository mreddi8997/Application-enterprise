resource "aws_route53_record" "petclinic" {
  count = var.route53_alias == null ? 0 : 1

  zone_id = var.route53_alias.hosted_zone_id
  name    = var.route53_alias.record_name
  type    = "A"

  alias {
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = true
  }
}
