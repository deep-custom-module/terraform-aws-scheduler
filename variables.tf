variable "name" {
  type        = string
  default     = "terraform-scheduler"
  description = "Solution name, e.g. 'app' or 'jenkins'"
}

variable "timeouts" {
  type = map(string)
  default = {
    "1"  = "cron(0/1 * * * ? *)",
    "2"  = "cron(0/2 * * * ? *)",
    "5"  = "cron(0/5 * * * ? *)",
    "10" = "cron(0/10 * * * ? *)",
    "15" = "cron(0/15 * * * ? *)",
    "30" = "cron(0/30 * * * ? *)",
    "60" = "cron(0 0/1 * * ? *)"
  }
}

variable "log_retention" {
  type        = number
  default     = 30
  description = "Retention days for scheduler logs."
}

variable "memory_size" {
  type        = number
  default     = 128
  description = "Size of the Lambda function running the scheduler, increase size when processing large numbers of instances."
}

#lambda variables
variable "scheduler_frequency" {
  type        = string
  default     = "5"
  description = "Scheduler running frequency in m§inutes."
}

variable "tag_name" {
  type        = string
  default     = "Schedule"
  description = "Name of tag to use for associating instance schedule schemas with service instances."
}

variable "enable_cloudwatch" {
  default     = false
  type        = bool
  description = "Collect instance scheduling data using CloudWatch metrics."
}

variable "enable_ssm_maintenance_windows" {
  description = "Enable the solution to load SSM Maintenance Windows, so that they can be used for EC2 instance Scheduling."
  type        = bool
  default     = false
}

variable "started_tags" {
  type        = string
  default     = "auto=start"
  description = "Comma separated list of tagname and values on the format name=value,name=value,.. that are set on started instances"
}

variable "stopped_tags" {
  type        = string
  default     = "auto=stop"
  description = "Comma separated list of tagname and values on the format name=value,name=value,.. that are set on stopped instances"
}

variable "create_rds_snapshot" {
  type        = bool
  description = "Create snapshot before stopping RDS instances (does not apply to Aurora Clusters)."
  default     = false
}

variable "default_timezone" {
  description = "Choose the default Time Zone. Default is 'UTC'."
  type        = string
  default     = "UTC"
}

variable "schedule_clusters" {
  description = "Enable scheduling of Aurora clusters for RDS Service."
  type        = bool
  default     = false
}

variable "periods" {
  default = {}
}

variable "schedules" {
  default = {}
}