data "aws_ami" "petclinic_lab" {
  most_recent = true
  owners      = [var.aws_account_id]

  filter {
    name   = "name"
    values = [var.petclinic_ami_name]
  }
}

locals {
  cloud_config = {
    write_files = [
      {
        path        = "/etc/petclinic/database.json"
        permissions = "0600"
        content = jsonencode({
          region     = var.aws_region
          secret_arn = var.database_secret_arn
          jdbc_url   = var.database_jdbc_url
        })
      },
      {
        path        = "/usr/local/lib/petclinic-db-env.py"
        permissions = "0644"
        content     = file("${path.module}/petclinic-db-env.py")
      },
      {
        path        = "/etc/systemd/system/petclinic.service.d/50-database.conf"
        permissions = "0644"
        content     = <<-EOT
          [Service]
          EnvironmentFile=-/run/petclinic-db/database.env
          ExecStartPre=+/usr/bin/python3 /usr/local/lib/petclinic-db-env.py
          Restart=on-failure
          RestartSec=15s
        EOT
      }
    ]
    runcmd = [
      ["systemctl", "daemon-reload"],
      ["systemctl", "restart", "--no-block", "petclinic.service"]
    ]
  }
}

resource "aws_launch_template" "petclinic_app" {
  name_prefix            = "petclinic-app-"
  image_id               = data.aws_ami.petclinic_lab.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.petclinic_sg]
  user_data              = base64encode("#cloud-config\n${yamlencode(local.cloud_config)}")

  iam_instance_profile {
    name = aws_iam_instance_profile.petclinic.name
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
}

resource "aws_autoscaling_group" "petclinic_app_asg" {
  name                = "petclinic_app_asg"
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = var.target_group_arns

  launch_template {
    id      = aws_launch_template.petclinic_app.id
    version = aws_launch_template.petclinic_app.latest_version
  }

  tag {
    key                 = "Name"
    value               = "petclinic_app_instance"
    propagate_at_launch = true
  }

  depends_on = [
    aws_iam_role_policy.petclinic,
    aws_iam_role_policy_attachment.ssm
  ]
}

output "petclinic_app_asg_name" {
  value = aws_autoscaling_group.petclinic_app_asg.name
}
