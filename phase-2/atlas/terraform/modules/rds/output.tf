output "aws_rds_endpoint" {
  description = "The connection endpoint for RDS instance"
  value = module.db.db_instance_endpoint
}
