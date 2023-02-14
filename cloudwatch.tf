resource "aws_cloudwatch_log_group" "logs_scheduler" {
  name              = "${var.name}-scheduler-logs"
  retention_in_days = var.log_retention
  tags              = var.tags
}

resource "aws_cloudwatch_event_rule" "scheduler_frequency_role" {
  description         = "Instance Scheduler - Rule to trigger instance for scheduler function."
  name                = "SchedulerRule"
  schedule_expression = lookup(var.timeouts, var.scheduler_frequency)
  tags                = var.tags
}

resource "aws_cloudwatch_event_target" "scheduler_frequency_event_target" {
  arn  = module.lambda.function_arn
  rule = aws_cloudwatch_event_rule.scheduler_frequency_role.name
}