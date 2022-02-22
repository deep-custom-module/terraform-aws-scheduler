resource "aws_sns_topic" "instance_scheduler_topic" {
  kms_master_key_id = aws_kms_key.instance_scheduler_key.arn
  name              = "${var.name}-scheduler-topic"
  tags              = var.tags
}