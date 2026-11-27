# Petclinic development infrastructure

The public ALB forwards traffic to Petclinic on port 8080. Set an existing ACM certificate ARN to serve HTTPS and redirect HTTP clients. The Auto Scaling group uses private subnets, and the RDS PostgreSQL instance uses separate database subnets. The instances register with Systems Manager through the VPC's NAT gateway.

## Before planning

- Use Terraform 1.10 or later and AWS credentials for the target account. The default region is `us-east-2`.
- Use an existing Petclinic AMI owned by that account. Set `petclinic_ami_name` and `instance_type` if you use a different image or architecture. The AMI must have cloud-init, Python 3.8 or later, AWS CLI v2, SSM Agent, and the `petclinic.service` unit. The service should run the JAR at `/opt/petclinic/app.jar` so the existing deployment script can replace it.
- Use an existing private, versioned S3 state bucket. The Terraform execution role needs access to the state object and its `.tflock` companion. Use a separate state key per environment.

Run from the repository root, substituting the state bucket and its actual region.

```sh
terraform -chdir=infra init -reconfigure \
  -backend-config="bucket=YOUR_STATE_BUCKET" \
  -backend-config="region=YOUR_STATE_BUCKET_REGION" \
  -backend-config="key=petclinic/dev/terraform.tfstate"
terraform -chdir=infra validate
terraform -chdir=infra plan
```

If you already have local state for these resources, use `init -migrate-state` in place of `-reconfigure` to move that state to the selected S3 key.

## Initialize PostgreSQL and deploy

1. After the infrastructure is provisioned, use the `rds_endpoint`, `rds_database_name`, and `rds_master_secret_arn` outputs to connect as an administrator from a host with database access. An SSM session through a Petclinic instance can reach the private RDS endpoint. Retrieve the master secret with your operator credentials.
2. Have a database owner run the Petclinic [schema](../src/main/resources/db/postgres/schema.sql) and [seed data](../src/main/resources/db/postgres/data.sql) scripts. Create a separate application login with schema access, table permissions for the application, and sequence access. The application disables SQL initialization on startup so the runtime login needs no DDL permissions.
3. Populate the secret identified by `petclinic_database_secret_arn` in Secrets Manager with the application login's `username` and `password` as JSON string fields. The instance role reads this secret on each service start. Petclinic uses the `postgres` profile and verifies the RDS server certificate.
4. If the SSM deployment downloads from S3, set `release_bucket_name` and, if needed, `release_artifact_prefix` before planning. The default prefix is `petclinic/`, matching the release export in `buildspec.yaml`. If that bucket uses a customer-managed KMS key for the artifacts, the instance role also needs decrypt access to that key. Deploy with the existing SSM workflow, which restarts `petclinic.service`, and check that the ALB target is healthy.

## Use a custom domain

To publish the ALB under a custom hostname, add this block to `infra/terraform.tfvars`. Use the ID of your existing public Route 53 hosted zone and a full DNS name within that zone.

```hcl
route53_alias = {
  hosted_zone_id = "Z0123456789EXAMPLE"
  record_name    = "petclinic.example.com"
}
```

Check that the domain is delegated to this public hosted zone. Terraform creates an `A` alias to the ALB and returns the URL in `petclinic_domain_url`. If the A record already exists, import it into the existing Terraform state before applying. Leave `route53_alias` unset to use the ALB URL directly.

### Reuse an ACM certificate

Add the ARN of your existing **Issued** ACM certificate to the same `infra/terraform.tfvars` file.

```hcl
alb_certificate_arn = "arn:aws:acm:us-east-2:123456789012:certificate/00000000-0000-0000-0000-000000000000"
```

The certificate must cover the hostname and be in the same AWS account and region as the ALB. Check the certificate in ACM in **US East (Ohio)** for the current configuration. Setting the ARN enables public port 443 on the ALB and redirects HTTP to HTTPS. The HTTPS listener forwards to the existing Petclinic target group.

If you manage the DNS record separately, set just `alb_certificate_arn` and keep the existing alias directed at this ALB. If a live record points to another ALB, verify the new ALB's listener and target health before switching the record. If Terraform will manage an existing HTTPS listener on this same ALB, import that listener at `module.alb.aws_lb_listener.petclinic_https_listener[0]` before applying.
