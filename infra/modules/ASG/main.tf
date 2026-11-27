data "aws_ami" "petclinic_lab" {
  most_recent = true
  owners  = [tostring(var.aws_account_id)]
  

  filter {
    name   = "name"
    values = [var.petclinic_ami_name]
  }
  
}

data "iam_instance_profile" "petclinic_instance_profile" {
  name = var.petclinic_instance_profile_name



resource "aws_launch_configuration" "petclinic_app" {
  name          = "petclinic_app"
  image_id      = data.aws_ami.petclinic_lab.id
  instance_type = var.instance_type
  security_groups = [var.petclinic_sg]
  iam_instance_profile = data.iam_instance_profile.petclinic_instance_profile.id
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "petclinic_app_asg" {
  name                 = "petclinic_app_asg" 
  desired_capacity     = var.desired_capacity
  max_size             = var.max_size
  min_size             = var.min_size
  vpc_zone_identifier  = [var.subnet_ids]
  launch_configuration = aws_launch_configuration.petclinic_app.id

  tag {
    key                 = "Name"
    value               = "petclinic_app_instance"
    propagate_at_launch = true
  }
}

output "petclinic_app_asg_name" {
  value = aws_autoscaling_group.petclinic_app_asg.name
}
