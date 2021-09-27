resource "aws_kms_key" "instance_scheduler_key" {
  description         = "Key for SNS"
  policy              = data.template_file.kms_key_policy.rendered
  is_enabled          = true
  enable_key_rotation = true
  tags = var.tags
}

data "template_file" "kms_key_policy" {
  template = file("${path.module}/templates/kms_key_policy.json")
  vars = {
    account_id         = data.aws_caller_identity.current.account_id
    scheduler_role_arn = aws_iam_role.scheduler_role.arn
  }
}

resource "aws_kms_alias" "instance_scheduler_alias" {
  target_key_id = aws_kms_key.instance_scheduler_key.arn
  name          = "alias/${var.name}-instance-scheduler-encryption-key"
}