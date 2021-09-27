locals {
  environment_map = local.variables == null ? [] : [local.variables]
}

locals {
  variables = {
    SCHEDULER_FREQUENCY    = var.scheduler_frequency
    TAG_NAME               = var.tag_name
    LOG_GROUP              = aws_cloudwatch_log_group.logs_scheduler.name
    ACCOUNT                = data.aws_caller_identity.current.account_id
    ISSUES_TOPIC_ARN       = aws_sns_topic.instance_scheduler_topic.arn
    STACK_NAME             = var.name
    BOTO_RETRY             = "5,10,30,0.25",
    ENV_BOTO_RETRY_LOGGING = "FALSE",
    USER_AGENT : "InstanceScheduler-${var.name}-v1.4.0"
    USER_AGENT_EXTRA : "AwsSolution/SO0030/v1.4.0",
    START_EC2_BATCH_SIZE : 5,
    SEND_METRICS : "False",
    METRICS_URL : "https://metrics.awssolutionsbuilder.com/generic"
    DDB_TABLE_NAME : aws_dynamodb_table.state_table.name
    CONFIG_TABLE : aws_dynamodb_table.config_table.name
    MAINTENANCE_WINDOW_TABLE : aws_dynamodb_table.maintenance_table.name
    STATE_TABLE : aws_dynamodb_table.state_table.name
    SOLUTION_ID : "S00030",
    UUID_KEY : "/Solutions/aws-instance-scheduler/UUID/"
    TRACE : "False"
    ENABLE_SSM_MAINTENANCE_WINDOWS : var.enable_ssm_maintenance_windows
  }
}

resource "aws_lambda_function" "instance_scheduler_main" {
  function_name                  = "${var.name}_InstanceSchedulerMain"
  handler                        = "main.lambda_handler"
  publish                        = false
  s3_bucket                      = "solutions-${data.aws_region.current.name}"
  s3_key                         = "aws-instance-scheduler/v1.4.0/instance-scheduler.zip"
  description                    = "EC2 and RDS instance scheduler, version v1.4.0"
  role                           = aws_iam_role.scheduler_role.arn
  reserved_concurrent_executions = 100
  memory_size                    = var.memory_size
  runtime                        = "python3.7"
  timeout                        = 300
  dynamic "environment" {
    for_each = local.environment_map
    content {
      variables = environment.value
    }
  }
  tracing_config {
    mode = "Active"
  }
  depends_on = [aws_iam_role.scheduler_role]
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.instance_scheduler_main.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.scheduler_frequency_role.arn
}