variable "name" {
  type        = string
  default     = "terraform-scheduler"
  description = "Solution name, e.g. 'app' or 'jenkins'"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the object"
  default     = {}
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