module "sns" {
  source  = "ptfe-crx5x8zy.deeptpe.pmicloud.xyz/core-prd/sns/aws"
  version = "1.0.1"
  name = "${var.name}-scheduler-topic"
  tags =  var.tags
  kms_master_key_id = module.kms.key_id
  protocol = "email"
  endpoints = [var.email_subscriber_sns]
}