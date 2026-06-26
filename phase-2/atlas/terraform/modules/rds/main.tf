module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = var.rds_identifier
  engine     = var.rds_engine

  engine_version    = var.rds_engine_version
  instance_class    = var.rds_instance_class
  allocated_storage = var.rds_allocated_storage

  db_name  = var.rds_db_name
  username = var.rds_username
  port     = var.rds_port

  iam_database_authentication_enabled = var.rds_iam_database_authentication_enabled

  vpc_security_group_ids = var.rds_vpc_security_group_ids

  maintenance_window = var.rds_maintenance_window
  backup_window      = var.rds_backup_window

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval    = var.rds_monitoring_interval
  monitoring_role_name   = var.rds_monitoring_role_name
  create_monitoring_role = var.rds_create_monitoring_role

  tags = var.rds_tags

  # DB subnet group
  create_db_subnet_group = var.rds_create_db_subnet_group
  subnet_ids             = var.rds_subnet_ids

  # DB parameter group
  family = var.rds_family

  # DB option group
  major_engine_version = var.rds_major_engine_version

  # Database Deletion Protection
  deletion_protection = var.rds_deletion_protection

  parameters = var.rds_parameters
  options    = var.rds_options
}
