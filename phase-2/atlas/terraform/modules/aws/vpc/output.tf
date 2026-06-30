output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "ID of VPC"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnets
  description = "IDs of the private subnets created for the VPC."
}
