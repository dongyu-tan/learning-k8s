variable "rds_identifier" {
  type        = string
  description = "DB identifier"
}

variable "rds_engine" {
  type        = string
  description = "Database engine (for example, postgres)"
}

variable "rds_engine_version" {
  type        = string
  description = "Database engine version."
}

variable "rds_instance_class" {
  type        = string
  description = "RDS instance class."
}

variable "rds_allocated_storage" {
  type        = number
  description = "Allocated storage in GiB."
}

variable "rds_db_name" {
  type        = string
  description = "Initial database name."
}

variable "rds_username" {
  type        = string
  description = "Master database username."
}

variable "rds_port" {
  type        = number
  description = "Database listener port."
}

variable "rds_iam_database_authentication_enabled" {
  type        = bool
  description = "Whether IAM database authentication is enabled."
}

variable "rds_vpc_security_group_ids" {
  type        = list(string)
  description = "Security group IDs attached to the database."
}

variable "rds_maintenance_window" {
  type        = string
  description = "Weekly maintenance window in UTC."
}

variable "rds_backup_window" {
  type        = string
  description = "Daily backup window in UTC."
}

variable "rds_monitoring_interval" {
  type        = number
  description = "Enhanced Monitoring interval in seconds; use 0 to disable."
}

variable "rds_monitoring_role_name" {
  type        = string
  description = "Name for the Enhanced Monitoring IAM role."
}

variable "rds_create_monitoring_role" {
  type        = bool
  description = "Whether to create the Enhanced Monitoring IAM role."
}

variable "rds_tags" {
  type        = map(string)
  description = "Tags to apply to RDS resources."
}

variable "rds_create_db_subnet_group" {
  type        = bool
  description = "Whether to create a DB subnet group."
}

variable "rds_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for the DB subnet group."
}

variable "rds_family" {
  type        = string
  description = "DB parameter-group family."
}

variable "rds_major_engine_version" {
  type        = string
  description = "Major engine version for the DB option group."
}

variable "rds_deletion_protection" {
  type        = bool
  description = "Whether deletion protection is enabled."
}

variable "rds_parameters" {
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string)
  }))
  description = "Parameter group settings."
}

variable "rds_options" {
  type = list(object({
    option_name = string
    option_settings = list(object({
      name  = string
      value = string
    }))
  }))
  description = "Option group settings."
}
