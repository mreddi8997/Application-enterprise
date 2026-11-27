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
  rds_allowed_security_groups = [module.SG.petclinic_sg]

  rds_db_name  = "petclinic_lab"
  rds_username = "petclinic_admin"
}

module "alb" {
  source = "./modules/ALB"

subnet_ids = module.vpc.public_subnet_ids
vpc = module.vpc.vpc_id

}

module "ASG" {
  source = "./modules/ASG"

petclinic_sg = module.SG.petclinic_sg.id
instance_type = t3.micro
}

module "cloudwatch" {
  source = "./modules/cloudwatch"
}

module "SG" {
  source = "./modules/SG"
}
