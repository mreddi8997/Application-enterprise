variable "vpc_id" {
  type = string
}

variable "alb_listener_port" {
  type = number
}

variable "app_port" {
  type = number
}

variable "database_subnet_cidrs" {
  type = list(string)
}

resource "aws_security_group" "petclinic_alb_sg" {
  name        = "petclinic_alb_sg"
  description = "Public HTTP access to the Petclinic ALB"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "alb_listener" {
  security_group_id = aws_security_group.petclinic_alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = var.alb_listener_port
  to_port           = var.alb_listener_port
}

resource "aws_security_group" "petclinic_sg" {
  name        = "petclinic_sg"
  description = "Security group for Petclinic application"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.petclinic_alb_sg.id]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.database_subnet_cidrs
  }

  egress {
    description = "HTTPS to Systems Manager, Secrets Manager, and S3 through NAT"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_security_group_egress_rule" "alb_to_petclinic" {
  security_group_id            = aws_security_group.petclinic_alb_sg.id
  referenced_security_group_id = aws_security_group.petclinic_sg.id
  ip_protocol                  = "tcp"
  from_port                    = var.app_port
  to_port                      = var.app_port
}

output "petclinic_sg" {
  value = aws_security_group.petclinic_sg.id
}

output "alb_security_group_id" {
  value = aws_security_group.petclinic_alb_sg.id
}
