locals {
  vpc_name          = "petclinic-dev"
  alb_listener_port = 80
  app_port          = 8080
  database_name     = "petclinic_lab"
  database_subnets  = ["10.0.5.0/24", "10.0.6.0/24"]
}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}

module "vpc" {
  source = "git::https://github.com/mreddi8997/Enterprise-Mobility-Request-Portal.git//Infra/modules/vpc?ref=d65a301dc24c69a1835a6182417c21c74aea5a2f"

  vpc_name           = local.vpc_name
  availability_zones = slice(sort(data.aws_availability_zones.available.names), 0, 2)
  rds_subnets        = local.database_subnets
}

module "rds" {
  source = "git::https://github.com/mreddi8997/Enterprise-Mobility-Request-Portal.git//Infra/modules/rds?ref=d65a301dc24c69a1835a6182417c21c74aea5a2f"

  vpc_id                      = module.vpc.vpc_id
  vpc_name                    = module.vpc.vpc_name
  rds_db_subnet_ids           = module.vpc.rds_subnet_ids
  rds_allowed_security_groups = [module.SG.petclinic_sg]
  rds_db_name                 = local.database_name
  rds_username                = "petclinic_admin"
}

module "alb" {
  source = "./modules/ALB"

  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.public_subnet_ids
  alb_security_group_id = module.SG.alb_security_group_id
  alb_listener_port     = local.alb_listener_port
  alb_target_group_port = local.app_port
}

module "ASG" {
  source = "./modules/ASG"

  aws_account_id          = data.aws_caller_identity.current.account_id
  petclinic_ami_name      = var.petclinic_ami_name
  instance_type           = var.instance_type
  petclinic_sg            = module.SG.petclinic_sg
  subnet_ids              = module.vpc.private_subnet_ids
  target_group_arns       = [module.alb.target_group_arn]
  aws_region              = var.aws_region
  database_secret_arn     = module.petclinic_secret.secret_arn
  database_jdbc_url       = "jdbc:postgresql://${module.rds.db_instance_endpoint}/${local.database_name}?sslmode=verify-full&sslrootcert=/run/petclinic-db/rds-ca.pem"
  release_bucket_name     = var.release_bucket_name
  release_artifact_prefix = var.release_artifact_prefix

  depends_on = [module.vpc, module.SG]
}

module "cloudwatch" {
  source = "./modules/cloudwatch"

  autoscaling_group_name = module.ASG.petclinic_app_asg_name
}

module "SG" {
  source = "./modules/SG"

  vpc_id                = module.vpc.vpc_id
  alb_listener_port     = local.alb_listener_port
  app_port              = local.app_port
  database_subnet_cidrs = local.database_subnets
}

module "petclinic_secret" {
  source = "./modules/SecretsManager"

  name = "${local.vpc_name}/database/application"
}
