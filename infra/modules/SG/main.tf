resource "aws_security_group" "petclinic_sg" {
  name        = "petclinic_sg"
  description = "Security group for Petclinic application"
  vpc_id      = aws_vpc.main.id

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

output "petclinic_sg" {
  value = aws_security_group.petclinic_sg.id
}
