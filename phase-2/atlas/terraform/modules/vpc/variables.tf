variable "vpc_name" {
  type        = string
  description = "Capstone 1 VPC Name"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR value for VPC"
}

variable "vpc_azs" {
  type        = list(string)
  description = "List of Availability Zones"
}

variable "vpc_private_subnets" {
  type        = list(string)
  description = "List of Private Subnets"
}

variable "vpc_public_subnets" {
  type        = list(string)
  description = "List of Public Subnets"
}

variable "vpc_enable_nat_gateway" {
  type        = bool
  description = "NAT Gateway status"
}

variable "vpc_single_nat_gateway" {
  type        = bool
  description = "Single NAT Gateway Status"
}

variable "vpc_enable_vpn_gateway" {
  type        = bool
  description = "VPN Gateway status"
}

variable "vpc_terraform" {
  type        = string
  description = "VPC Terraform status"
}

variable "vpc_environment" {
  type        = string
  description = "VPC Environment"
}
