#####################################################
# IBM Cloud Satellite -  AWS
# Copyright 2021 IBM
#####################################################

output "location_id" {
  value = module.satellite-location.location_id
}

output "location_zones" {
  description = "A list of availability zones specified as argument to this module"
  value       = local.azs
}

output "host_script" {
  value = module.satellite-location.host_script
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = module.vpc.vpc_arn
}

output "default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = module.vpc.default_security_group_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "location-ec2-private_dns" {
  value = module.satellite-location-ec2.private_dns
}

output "cluster-ec2-private_dns" {
  value = module.satellite-cluster-ec2.private_dns
}

output "cluster_id" {
  value = var.create_cluster ? module.satellite-cluster.cluster_id : ""
}

output "cluster_crn" {
  value = var.create_cluster ? module.satellite-cluster.cluster_crn : ""
}

output "server_url" {
  value = var.create_cluster ? module.satellite-cluster.server_url : ""
}

output "cluster_state" {
  value = var.create_cluster ? module.satellite-cluster.cluster_state : ""
}

output "cluster_status" {
  value = var.create_cluster ? module.satellite-cluster.cluster_status : ""
}

output "ingress_hostname" {
  value = var.create_cluster ? module.satellite-cluster.ingress_hostname : ""
}

output "cluster_worker_pool_id" {
  value = var.create_cluster_worker_pool ? module.satellite-cluster-worker-pool.worker_pool_id : ""
}

output "worker_pool_worker_count" {
  value = var.create_cluster_worker_pool ? module.satellite-cluster-worker-pool.worker_pool_worker_count : ""
}

output "worker_pool_zones" {
  value = var.create_cluster_worker_pool ? module.satellite-cluster-worker-pool.worker_pool_zones : []
}