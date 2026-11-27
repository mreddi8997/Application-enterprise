output "petclinic_url" {
  description = "HTTP URL of the Petclinic development ALB."
  value       = module.alb.url
}

output "autoscaling_group_name" {
  value = module.ASG.petclinic_app_asg_name
}

output "rds_endpoint" {
  value = module.rds.db_instance_endpoint
}

output "rds_database_name" {
  value = module.rds.name
}

output "rds_master_secret_arn" {
  description = "RDS-managed secret ARN for database administration."
  value       = module.rds.db_master_secret_arn
}

output "petclinic_database_secret_arn" {
  description = "Secret ARN for the application's separate PostgreSQL login."
  value       = module.petclinic_secret.secret_arn
}

output "petclinic_domain_url" {
  description = "URL of the optional Route 53 alias."
  value = var.route53_alias == null ? null : format(
    "%s://%s",
    var.alb_certificate_arn == null ? "http" : "https",
    trimsuffix(aws_route53_record.petclinic[0].fqdn, ".")
  )
}
