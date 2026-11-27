resource "aws_security_group" "petclinic_sg" {
  name        = "petclinic_sg"
  description = "Security group for Petclinic application"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    egress {
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_vpc_security_group_ingress_rule" "example" {
  security_group_id = aws_security_group.petclinic_sg.id

  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}


output "petclinic_sg" {
  value = aws_security_group.petclinic_sg.id
}
variable "vpc_id" {
  type = string
}

variable "sg_id"
  type = string
}
