variable "name" {
  type = string
}

resource "aws_secretsmanager_secret" "this" {
  name        = var.name
  description = "PostgreSQL credentials for the Petclinic application"
}

output "secret_arn" {
  value = aws_secretsmanager_secret.this.arn
}
