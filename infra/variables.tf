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

variable "route53_alias" {
  description = "Optional public Route 53 A alias for the Petclinic ALB. Use the hosted zone ID and the full DNS record name."
  type = object({
    hosted_zone_id = string
    record_name    = string
  })
  default = null

  validation {
    condition     = var.route53_alias == null ? true : try(trimspace(var.route53_alias.hosted_zone_id) != "" && trimspace(var.route53_alias.record_name) != "", false)
    error_message = "Set both hosted_zone_id and record_name when configuring a Route 53 alias."
  }
}

variable "alb_certificate_arn" {
  description = "Existing ACM certificate ARN for the public ALB HTTPS listener. Leave unset for HTTP-only operation."
  type        = string
  default     = null

  validation {
    condition     = var.alb_certificate_arn == null || can(regex("^arn:[^:]+:acm:[a-z0-9-]+:[0-9]{12}:certificate/[0-9a-fA-F-]+$", var.alb_certificate_arn))
    error_message = "Use the ACM certificate ARN for the application hostname."
  }
}
