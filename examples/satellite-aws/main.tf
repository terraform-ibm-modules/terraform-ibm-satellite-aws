#####################################################
# IBM Cloud Satellite -  AWS Example
# Copyright 2021 IBM
#####################################################

###################################################################
# Provision satellite location on IBM cloud with AWS host
###################################################################
module "satellite-aws" {
  source = "../.."

  ibmcloud_api_key           = var.ibmcloud_api_key
  aws_region                 = var.aws_region
  aws_access_key             = var.aws_access_key
  aws_secret_key             = var.aws_secret_key
  resource_group             = var.resource_group
  is_location_exist          = var.is_location_exist
  location                   = var.location
  managed_from               = var.managed_from
  location_zones             = var.location_zones
  location_bucket            = var.location_bucket
  host_labels                = var.host_labels
  host_provider              = "aws"
  create_cluster             = var.create_cluster
  cluster                    = var.cluster
  cluster_host_labels        = var.cluster_host_labels
  create_cluster_worker_pool = var.create_cluster_worker_pool
  worker_pool_name           = var.worker_pool_name
  worker_pool_host_labels    = var.worker_pool_host_labels
  create_timeout             = var.create_timeout
  update_timeout             = var.update_timeout
  delete_timeout             = var.delete_timeout
}