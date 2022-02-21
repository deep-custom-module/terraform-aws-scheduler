locals {
  regions = [data.aws_region.current.name]

  periods = toset(flatten([
    for period_name, period in var.periods : {
      name        = period_name
      description = try(period.description, false) == false ? jsonencode({ "NULL" = true }) : jsonencode({ "S" = period.description })
      begintime   = try(period.begintime, false) == false ? jsonencode({ "NULL" = true }) : jsonencode({ "S" = period.begintime })
      endtime     = try(period.endtime, false) == false ? jsonencode({ "NULL" = true }) : jsonencode({ "S" = period.endtime })
      weekdays    = period.weekdays
    }
  ]))

  schedules = toset(flatten([
    for schedule_name, schedule in var.schedules : {
      name            = schedule_name
      override_status = try(schedule.override_status, false) == false ? jsonencode({ "NULL" = true }) : jsonencode({ "S" = schedule.override_status })
      description     = try(schedule.description, false) == false ? jsonencode({ "NULL" = true }) : jsonencode({ "S" = schedule.description })
      timezone        = try(schedule.timezone, false) == false ? jsonencode({ "NULL" = true }) : jsonencode({ "S" = schedule.timezone })
      use_metrics     = try(schedule.use_metrics, false) == false ? jsonencode({ "NULL" = true }) : jsonencode({ "BOOL" = schedule.use_metrics })
      periods         = schedule.periods
    }
  ]))
}

resource "aws_dynamodb_table" "state_table" {
  range_key = "account-region"
  hash_key  = "service"
  name      = "StateTable"
  point_in_time_recovery {
    enabled = true
  }
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "service"
    type = "S"
  }

  attribute {
    name = "account-region"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.instance_scheduler_key.arn
  }
  tags = var.tags
}

resource "aws_dynamodb_table" "config_table" {
  range_key = "name"
  hash_key  = "type"
  name      = "ConfigTable"
  point_in_time_recovery {
    enabled = true
  }
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "type"
    type = "S"
  }

  attribute {
    name = "name"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.instance_scheduler_key.arn
  }
  tags = var.tags

  provisioner "local-exec" {
    command = "aws dynamodb batch-write-item --request-items file://periods.json --region ${data.aws_region.current.name}"
  }
  provisioner "local-exec" {
    command = "aws dynamodb batch-write-item --request-items file://mon-7am-fri-8pm.json --region ${data.aws_region.current.name}"
  }
  provisioner "local-exec" {
    command = "aws dynamodb batch-write-item --request-items file://mon-9am-fri-5pm.json --region ${data.aws_region.current.name}"
  }
  provisioner "local-exec" {
    command = "aws dynamodb batch-write-item --request-items file://mon-fri-all-day.json --region ${data.aws_region.current.name}"
  }
  provisioner "local-exec" {
    command = "aws dynamodb batch-write-item --request-items file://sat-9am-sun-8pm.json --region ${data.aws_region.current.name}"
  }
  provisioner "local-exec" {
    command = "aws dynamodb batch-write-item --request-items file://sat-sun-all-day.json --region ${data.aws_region.current.name}"
  }
}

resource "aws_dynamodb_table" "maintenance_table" {
  range_key = "account-region"
  hash_key  = "Name"
  name      = "MaintenanceWindow"
  point_in_time_recovery {
    enabled = true
  }
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "Name"
    type = "S"
  }

  attribute {
    name = "account-region"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.instance_scheduler_key.arn
  }
  tags = var.tags
}

#definition of config
resource "aws_dynamodb_table_item" "config_initialization" {
  table_name = aws_dynamodb_table.config_table.name
  range_key  = aws_dynamodb_table.config_table.range_key
  hash_key   = aws_dynamodb_table.config_table.hash_key

  item = <<ITEM
{
  "type": {"S": "config"},
  "name": {"S": "scheduler"},
  "enable_SSM_maintenance_windows": {"BOOL": ${var.enable_ssm_maintenance_windows}},
  "regions": {"SS": ${jsonencode(local.regions)}},
  "scheduled_services": {"SS": ${jsonencode(["ec2", "rds"])}},
  "stopped_tags": {"S": "${var.stopped_tags}"},
  "create_rds_snapshot": {"BOOL": ${var.create_rds_snapshot}},
  "default_timezone": {"S": "${var.default_timezone}"},
  "trace": {"BOOL": false},
  "started_tags": {"S": "${var.started_tags}"},
  "schedule_clusters": {"BOOL": ${var.schedule_clusters}},
  "use_metrics": {"BOOL": ${var.enable_cloudwatch}},
  "tagname": {"S": "${var.tag_name}"},
  "schedule_lambda_account": {"BOOL": true}
}
ITEM
}

#definition of periods
resource "aws_dynamodb_table_item" "periods" {
  for_each = {
    for period in local.periods : period.name => period
  }

  table_name = aws_dynamodb_table.config_table.name
  range_key  = aws_dynamodb_table.config_table.range_key
  hash_key   = aws_dynamodb_table.config_table.hash_key

  item = <<PERIOD
{
  "type": { "S": "period" },
  "name":  { "S":"${each.key}"},
  "description": ${each.value.description},
  "begintime": ${each.value.begintime},
  "endtime": ${each.value.endtime},
  "weekdays": {"SS": ${jsonencode(each.value.weekdays)}}
}
PERIOD
}

#definition of schedules
resource "aws_dynamodb_table_item" "schedules" {
  for_each = {
    for schedule in local.schedules : schedule.name => schedule
  }
  table_name = aws_dynamodb_table.config_table.name
  range_key  = aws_dynamodb_table.config_table.range_key
  hash_key   = aws_dynamodb_table.config_table.hash_key

  item = <<SCHEDULE
  {
  "type": { "S": "schedule" },
  "timezone": ${each.value.timezone},
  "name": { "S":"${each.key}"},
  "description": ${each.value.description},
  "override_status": ${each.value.override_status},
  "periods": {"SS": ${jsonencode(each.value.periods)}},
  "use_metrics": ${each.value.use_metrics}
}
SCHEDULE
}

