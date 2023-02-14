data "template_file" "kms_key_policy" {
  template = file("${path.module}/templates/kms_key_policy.json")
  vars = {
    account_id         = data.aws_caller_identity.current.account_id
    scheduler_role_arn = aws_iam_role.scheduler_role.arn
  }
}

module "kms" {
  source  = "ptfe-crx5x8zy.deeptpe.pmicloud.xyz/core-prd/kms/aws"
  version = "1.0.1"
  custom_policy = data.template_file.kms_key_policy.rendered
  tags = var.tags
  alias = "${var.name}-instance-scheduler-encryption-key"
}