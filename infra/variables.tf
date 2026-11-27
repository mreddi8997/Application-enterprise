variable "aws_region" {
  description = "AWS region where the Petclinic AMI and infrastructure are located."
  type        = string
  default     = "us-east-2"
}

variable "petclinic_ami_name" {
  description = "Name of the prebuilt Petclinic AMI in the current AWS account."
  type        = string
  default     = "petclinic_app"
}

variable "instance_type" {
  description = "EC2 instance type for Petclinic. Its architecture must match the AMI."
  type        = string
  default     = "t3.micro"
}

variable "release_bucket_name" {
  description = "S3 bucket containing application release artifacts. Set it for SSM deployments that download from S3."
  type        = string
  default     = null
}

variable "release_artifact_prefix" {
  description = "S3 key prefix the instance role can read in the release bucket."
  type        = string
  default     = "petclinic/"
}
