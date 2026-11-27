variable "aws_account_id" {
  type = number
  default = 431445718171
}

variable "petclinic_ami_name" {
  type = string
  default = "petclinic_app"
}

variable "petclinic_instance_profile_name" {
  type = string
  default = "ec2admin"
}

variable "instance_type" {
  type = string
}

variable "desired_capacity" {
  type = number
  default = 1
}

variable "max_size" {
  type = number
  default = 2
}

variable "min_size" {
  type = number
  default = 1
}

variable "petclinic_sg"
  type = string
}

variable "subnet_ids"
  type = string
}
