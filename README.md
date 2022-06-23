#Scheduler Configuration table


When deployed, the AWS Instance Scheduler creates an Amazon DynamoDB table that contains global configuration settings. To modify these global configuration settings after the solution is deployed via terraform, update the terraform file. Do not modify these values in the DynamoDB table. If you modify the values in the DynamoDB table, you will create a conflict between the stored parameters in the state and the values in the table.

Global configuration items contain a type attribute with a value of config in the configuration table. Schedules and periods contain type attributes with values of schedule and period, respectively. You can add, update, or remove schedules and periods by adding proper maps as the argument in terraform file

Inputs to module

| Name | Description | Type | Default | Required | 
| ------ | ------ | ------ | ------ | ------ |
| name | The name used to identify the schedule. This name must be unique. | string |  | yes
| tag_name | Name of tag to use for associating instance schedule schemas with service instances. | string | Schedule | no
| periods | Map contains maps of scheduled rules for scheduler. Period rules contain conditions that allow you to set the specific hours, days, and months an instance will run. A period rule can contain multiple conditions, but all conditions must be true for the AWS Instance Scheduler to apply the appropriate start or stop action. Each schedule must contain at least one period that defines the time(s) the instance should run. A schedule can contain more than one period. When more than one period is used in a schedule, the Instance Scheduler will apply the appropriate start action when at least one of the period rules is true. see period definition how to use it.| map | | yes |
| schedules | Schedules specify when Amazon Elastic Compute Cloud (Amazon EC2) and Amazon Relational Database Service (Amazon RDS) instances should run. Each schedule must have a unique name, which is used as the tag value that identifies the schedule you want to apply to the tagged resource. see schedules definitions how to use it | map | | yes
| default_timezone | The default Time Zone. | string | UTC | no
| scheduler_frequency | Scheduler running frequency in minutes. | string | 5 | no
| enable_cloudwatch | Enable logging of detailed information in CloudWatch logs. | bool | false | no
| enable_ssm_maintenance_windows | Enable the solution to load SSM Maintenance Windows, so that they can be used for EC2 instance Scheduling.| bool | false | no
| started_tags | Comma separated list of tagname and values on the formt name=value,name=value,.. that are set on started instances | string | auto=start | no
| stopped_tags | Comma separated list of tagname and values on the formt name=value,name=value,.. that are set on stopped instances | string | auto=stop | no
| create_rds_snapshot | Create snapshot before stopping RDS instances (does not apply to Aurora Clusters). | bool | false | no
| schedule_clusters | Enable scheduling of Aurora clusters for RDS Service. | bool | false | no
| memory_size | Size of the Lambda function running the scheduler, increase size when processing large numbers of instances. | number | 128 | no
| log_retention | Retention days for scheduler logs. | number | 30 | no
| tags | Map of tags which will be added to scheduler resources | map | {} | no

## Schedule definitions
The Instance Scheduler configuration table in Amazon DynamoDB contains schedule definitions. A schedule definition can contain the following fields:


| Field | Description
| ------ | ------ |
| description | The name used to identify the schedule. This name must be unique. | 
| hibernate | Choose whether to hibernate Amazon EC2 instances running Amazon Linux. When this field is set to true, the scheduler will hibernate instances when it stops them. Note that your instances must turn on hibernation and must meet the hibernation prerequisites. | 
| enforced |  Choose whether to enforce the schedule. When this field is set to true, the scheduler will stop a running instance if it is manually started outside of the running period or it will start an instance if it is stopped manually during the running period. |
| override_status | When this field is set to running, the instance will be started but not stopped until you stop it manually. When this field is set to stopped, the instance will be stopped but not started until you start it manually.|
| periods | You can also specify an instance type for the period using the syntax <period-name>@<instance-type>. For example, weekdays@t2.large. | 
| retain_running | Choose whether to prevent the solution from stopping an instance at the end of a running period if the instance was manually started before the beginning of the period. |
| ssm_maintenance_window | Choose whether to add an AWS Systems Manager maintenance window as a running period. Enter the name of a maintenance window. Note: To use this field, you must also set the use_maintenance_window parameter to true. |
| stop_new_instances | Choose whether to stop an instance the first time it is tagged if it is running outside of the running period. By default, this field is set to true.|
| timezone | The time zone the schedule will use. If no time zone is specified, the default time zone (UTC) is used. For a list of acceptable time zone values, refer to the TZ column of the List of TZ Database Time Zones.|
| use_maintenance_window | Choose whether to add an Amazon RDS maintenance window as a running period to an Amazon RDS instance schedule, or to add an AWS Systems Manager maintenance window as a running period to an Amazon EC2 instance schedule. For more information, refer to Amazon RDS Maintenance Window and SSM Maintenance Window Field.|
| use_metrics | Choose whether to turn on CloudWatch metrics at the schedule level. This field overwrites the CloudWatch metrics setting you specified at deployment. Note: Enabling this feature will incur charges of $0.90/month per schedule or scheduled service. |

## Period definitions
The Instance Scheduler configuration table in Amazon DynamoDB contains period definitions. A period definition can contain the following fields. Note that some fields support Cron non-standard characters.

| Field | Description
| ------ | ------ |
| description | An optional description of the period rule | 
| begintime | An optional description of the period rule |
| endtime | The time, in HH:MM format, that the instance will stop. |
| months | Enter a comma-delimited list of months, or a hyphenated range of months, during which the instance will run. For example, enter jan, feb, mar or 1, 2, 3 to run an instance during those months. Or, you can enter jan-mar or 1-3. You can also schedule an instance to run every nth month or every nth month in a range. For example, enter Jan/3 or 1/3 to run an instance every third month starting in January. Enter Jan-Jul/2 to run every other month from January to July.|
| monthdays | Enter a comma-delimited list of days of the month, or a hyphenated range of days, during which the instance will run. For example, enter 1, 2, 3 or 1-3 to run an instance during the first three days of the month. You can also enter multiple ranges. For example, enter 1-3, 7-9 to run an instance from the 1st to the 3rd and the 7th through the 9th. You can also schedule an instance to run every nth day of the month or every nth day of the month in a range. For example, enter 1/7 to run an instance every seventh day starting on the 1st. Enter 1-15/2 to run an instance every other day from the 1st to the 15th.  Enter L to run an instance on the last day of the month. Enter a date and W to run an instance on the nearest weekday to the specified date. For example, enter 15W to run an instance on the nearest weekday to the 15th. |
| weekdays |  Enter a comma-delimited list of days of the week, or a range of days of the week, during which the instance will run. For example, enter 0, 1, 2 or 0-2 to run an instance Monday through Wednesday. You can also enter multiple ranges. For example, enter 0-2, 4-6 to run an instance every day except Thursday. You can also schedule an instance to run every nth occurrence of a weekday in the month. For example, enter Mon#1 or 0#1 to run an instance the first Monday of the month. Enter a day and L to run an instance on the last occurrence of that weekday in the month. For example, enter friL or 4L to run an instance on the last Friday of the month. 
              
      
                        
            
