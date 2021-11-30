#####################################################
# IBM Cloud Satellite -  AWS
# Copyright 2021 IBM
#####################################################

output "location_id" {
  value = module.satellite-aws.location_id
}

output "location_zones" {
  description = "A list of availability zones specified as argument to this module"
  value       = module.satellite-aws.location_zones
}

output "host_script" {
  value = module.satellite-aws.host_script
}

output "vpc_id" {
  value = module.satellite-aws.vpc_id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = module.satellite-aws.vpc_arn
}

output "default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = module.satellite-aws.default_security_group_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.satellite-aws.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.satellite-aws.public_subnets
}

output "location-ec2-private_dns" {
  value = module.satellite-aws.location-ec2-private_dns
}

output "cluster-ec2-private_dns" {
  value = module.satellite-aws.cluster-ec2-private_dns
}

output "cluster_id" {
  value = var.create_cluster ? module.satellite-aws.cluster_id : ""
}

output "cluster_crn" {
  value = var.create_cluster ? module.satellite-aws.cluster_crn : ""
}

output "server_url" {
  value = var.create_cluster ? module.satellite-aws.server_url : ""
}

output "cluster_state" {
  value = var.create_cluster ? module.satellite-aws.cluster_state : ""
}

output "cluster_status" {
  value = var.create_cluster ? module.satellite-aws.cluster_status : ""
}

output "ingress_hostname" {
  value = var.create_cluster ? module.satellite-aws.ingress_hostname : ""
}

output "cluster_worker_pool_id" {
  value = var.create_cluster_worker_pool ? module.satellite-aws.cluster_worker_pool_id : ""
}

output "worker_pool_worker_count" {
  value = var.create_cluster_worker_pool ? module.satellite-aws.worker_pool_worker_count : ""
}

output "worker_pool_zones" {
  value = var.create_cluster_worker_pool ? module.satellite-aws.worker_pool_zones : []
}