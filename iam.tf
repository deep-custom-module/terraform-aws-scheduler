resource "aws_iam_role" "instance_scheduler_lambda_service_role" {
  assume_role_policy = data.template_file.iam_assume_role_policy_document.rendered
  tags = var.tags
}

data "template_file" "iam_assume_role_policy_document" {
  template = file("${path.module}/templates/iam_role_lambda_assume.json")
}

data "template_file" "iam_role_lambda_function_service_policy_template" {
  template = file("${path.module}/templates/iam_role_lambda_function_service_policy.json")
  vars = {
    account_id = data.aws_caller_identity.current.account_id
    region     = data.aws_region.current.name
  }
}

resource "aws_iam_role_policy_attachment" "iam_role_lambda_function_service_policy_attach" {
  policy_arn = aws_iam_policy.iam_role_lambda_function_service_policy.arn
  role       = aws_iam_role.instance_scheduler_lambda_service_role.name
}

resource "aws_iam_policy" "iam_role_lambda_function_service_policy" {
  name   = "iam_role_lambda_function_service_policy"
  policy = data.template_file.iam_role_lambda_function_service_policy_template.rendered
}

#scheduler role
resource "aws_iam_role" "scheduler_role" {
  assume_role_policy = data.template_file.iam_assume_role_policy_scheduler_role.rendered
}

data "template_file" "iam_assume_role_policy_scheduler_role" {
  template = file("${path.module}/templates/iam_role_policy_scheduler_role.json")
}

resource "aws_iam_policy" "iam_role_scheduler_ec2_dynamodb_policy" {
  policy = data.template_file.iam_role_scheduler_ec2_dynamodb_policy_template.rendered
  name   = "iam_role_scheduler_ec2_dynamodb_policy"
}

data "template_file" "iam_role_scheduler_ec2_dynamodb_policy_template" {
  template = file("${path.module}/templates/ec2_dynamodb_policy.json")
  vars = {
    region     = data.aws_region.current.name
    account_id = data.aws_caller_identity.current.account_id
    name       = var.name
  }
}

resource "aws_iam_role_policy_attachment" "iam_role_scheduler_ec2_dynamodb_policy_attach" {
  policy_arn = aws_iam_policy.iam_role_scheduler_ec2_dynamodb_policy.arn
  role       = aws_iam_role.scheduler_role.name
}

#scheduler policy
resource "aws_iam_policy" "iam_role_scheduler_policy" {
  policy = data.template_file.iam_role_scheduler_policy_template.rendered
  name   = "iam_role_scheduler_policy"
}

data "template_file" "iam_role_scheduler_policy_template" {
  template = file("${path.module}/templates/scheduler_policy.json")
  vars = {
    region                         = data.aws_region.current.name
    dynamodb_config_table_arn      = aws_dynamodb_table.config_table.arn
    dynamodb_maintenance_table_arn = aws_dynamodb_table.maintenance_table.arn
    dynamodb_state_table_arn       = aws_dynamodb_table.state_table.arn
    account_id                     = data.aws_caller_identity.current.account_id
    name                           = var.name
    sns_topic_arn                  = aws_sns_topic.instance_scheduler_topic.arn
    kms_key_arn                    = aws_kms_key.instance_scheduler_key.arn
    lambda_arn                     = aws_lambda_function.instance_scheduler_main.arn
  }
}

resource "aws_iam_role_policy_attachment" "iam_role_scheduler_policy_attach" {
  policy_arn = aws_iam_policy.iam_role_scheduler_policy.arn
  role       = aws_iam_role.scheduler_role.name
}

#scheduler rds policy

resource "aws_iam_policy" "iam_role_rds_scheduler_policy" {
  policy = data.template_file.iam_role_rds_scheduler_policy_template.rendered
  name   = "iam_role_rds_scheduler_policy"
}

data "template_file" "iam_role_rds_scheduler_policy_template" {
  template = file("${path.module}/templates/rds_scheduler_policy.json")
  vars = {
    account_id = data.aws_caller_identity.current.account_id
  }
}

resource "aws_iam_role_policy_attachment" "iam_role_rds_scheduler_policy_attach" {
  policy_arn = aws_iam_policy.iam_role_rds_scheduler_policy.arn
  role       = aws_iam_role.scheduler_role.name
}

