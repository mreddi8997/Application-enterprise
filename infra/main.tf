module "vpc" {
  source = "git::https://github.com/mreddi8997/Enterprise-Mobility-Request-Portal.git//Infra/modules/vpc?ref=d65a301dc24c69a1835a6182417c21c74aea5a2f"

  vpc_name           = "petclinic-dev"
  availability_zones = ["us-east-2a", "us-east-2b"]

}

module "rds" {
  source = "git::https://github.com/mreddi8997/Enterprise-Mobility-Request-Portal.git//Infra/modules/rds?ref=d65a301dc24c69a1835a6182417c21c74aea5a2f"

  vpc_id                      = module.vpc.vpc_id
  vpc_name                    = module.vpc.vpc_name
  rds_db_subnet_ids           = module.vpc.rds_subnet_ids
  rds_allowed_security_groups = [aws_security_group.petclinic_sg.id]

  rds_db_name  = "petclinic_lab"
  rds_username = "petclinic_admin"
}

module "alb" {
  source = ./modules/ALB
}

module "ASG" {
  source = ./modules/ASG
}

module "cloudwatch" {
  source = ./modules/cloudwatch
}

