data "aws_partition" "current" {}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "petclinic" {
  name_prefix        = "petclinic-ec2-"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_instance_profile" "petclinic" {
  name_prefix = "petclinic-ec2-"
  role        = aws_iam_role.petclinic.name
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.petclinic.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "petclinic" {
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [var.database_secret_arn]
  }

  dynamic "statement" {
    for_each = var.release_bucket_name == null ? [] : [var.release_bucket_name]

    content {
      actions   = ["s3:GetObject", "s3:GetObjectVersion"]
      resources = ["arn:${data.aws_partition.current.partition}:s3:::${statement.value}/${var.release_artifact_prefix}*"]
    }
  }
}

resource "aws_iam_role_policy" "petclinic" {
  name   = "petclinic-runtime"
  role   = aws_iam_role.petclinic.name
  policy = data.aws_iam_policy_document.petclinic.json
}
