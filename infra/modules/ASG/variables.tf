variable "aws_account_id" {
  type = string
}

variable "petclinic_ami_name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "petclinic_sg" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "target_group_arns" {
  type = set(string)
}

variable "desired_capacity" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 1
}

variable "aws_region" {
  type = string
}

variable "database_secret_arn" {
  type = string
}

variable "database_jdbc_url" {
  type = string
}

variable "release_bucket_name" {
  type    = string
  default = null
}

variable "release_artifact_prefix" {
  type    = string
  default = "petclinic/"
}
