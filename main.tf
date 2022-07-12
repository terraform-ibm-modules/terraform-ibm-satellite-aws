#####################################################
# IBM Cloud Satellite -  AWS
# Copyright 2021 IBM
#####################################################

###################################################################
# Get the details about a specific availability zone (AZ) in the current region.
###################################################################
data "aws_availability_zones" "available" {
  state = "available"
}

###################################################################
# Create satellite location
###################################################################
module "satellite-location" {
  source  = "terraform-ibm-modules/satellite/ibm//modules/location"
  version = "1.1.9"

  is_location_exist = var.is_location_exist
  location          = var.location
  managed_from      = var.managed_from
  location_zones    = local.azs
  location_bucket   = var.location_bucket
  host_labels       = var.host_labels
  resource_group    = var.resource_group
  host_provider     = "aws"
}

###################################################################
# Create AWS VPC
###################################################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.14.2"

  name = "${var.resource_prefix}-vpc"
  cidr = "10.0.0.0/16"

  azs                = local.azs
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  enable_ipv6        = true
  enable_nat_gateway = false
  single_nat_gateway = true

  public_subnet_tags = {
    Name = var.resource_prefix
  }

  tags = {
    ibm-satellite = var.resource_prefix
  }

  vpc_tags = {
    Name = var.resource_prefix
  }
}

###################################################################
# Get the ID of a registered AMI
###################################################################
data "aws_ami" "redhat_linux" {
  owners = ["309956199498"]

  filter {
    name = "name"

    values = [
      "RHEL-7.7_HVM_GA-20190723-x86_64-1-Hourly2-GP2",
    ]
  }
}

###################################################################
# provision security group rules
###################################################################
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "${var.resource_prefix}-sg"
  description = "Security group for satellite usage with EC2 instance"
  vpc_id      = module.vpc.vpc_id

  tags = {
    ibm-satellite = var.resource_prefix
  }

  ingress_with_cidr_blocks = [
    {
      from_port   = 30000
      to_port     = 32767
      protocol    = "udp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 30000
      to_port     = 32767
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS TCP"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP TCP"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "All traffic"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  ingress_with_self = [
    {
      from_port = 0
      to_port   = 0
      protocol  = -1
      self      = true
    },
  ]

}

###################################################################
# provision placement group
###################################################################
resource "aws_placement_group" "satellite-group" {
  name     = "${var.resource_prefix}-pg"
  strategy = "spread"

  tags = {
    ibm-satellite = var.resource_prefix
  }

}

###################################################################
# provision SSH private key
###################################################################
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

###################################################################
# provision SSH key
###################################################################
resource "aws_key_pair" "keypair" {
  key_name   = "${var.resource_prefix}-ssh"
  public_key = var.ssh_public_key != null ? var.ssh_public_key : tls_private_key.example.public_key_openssh

  tags = {
    ibm-satellite = var.resource_prefix
  }

}

###################################################################
# Provision AWS EC2 host for control plane
###################################################################
module "satellite-location-ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.21.0"

  instance_count              = var.satellite_host_count
  name                        = "${var.resource_prefix}-location-host"
  use_num_suffix              = true
  ami                         = data.aws_ami.redhat_linux.id
  instance_type               = var.location_instance_type
  key_name                    = aws_key_pair.keypair.key_name
  subnet_ids                  = module.vpc.public_subnets
  vpc_security_group_ids      = [module.security_group.this_security_group_id]
  associate_public_ip_address = true
  placement_group             = aws_placement_group.satellite-group.id
  user_data                   = module.satellite-location.host_script

  tags = {
    ibm-satellite = var.resource_prefix
  }

}

###################################################################
# Provision AWS EC2 host for satellite ROKS cluster
###################################################################
module "satellite-cluster-ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.21.0"

  instance_count              = var.addl_host_count
  name                        = "${var.resource_prefix}-cluster-host"
  use_num_suffix              = true
  ami                         = data.aws_ami.redhat_linux.id
  instance_type               = var.cluster_instance_type
  key_name                    = aws_key_pair.keypair.key_name
  subnet_ids                  = module.vpc.public_subnets
  vpc_security_group_ids      = [module.security_group.this_security_group_id]
  associate_public_ip_address = true
  placement_group             = aws_placement_group.satellite-group.id
  user_data                   = module.satellite-location.host_script

  tags = {
    ibm-satellite = var.resource_prefix
  }

}

###################################################################
# Assign host to satellite location control plane
###################################################################
module "satellite-assign-host" {
  source         = "terraform-ibm-modules/satellite/ibm//modules/host"
  version        = "1.1.9"
  host_count     = var.satellite_host_count
  location       = module.satellite-location.location_id
  host_vms       = module.satellite-location-ec2.private_dns
  location_zones = local.azs
  host_labels    = var.host_labels
  host_provider  = "aws"

  depends_on = [module.satellite-location-ec2, module.satellite-cluster-ec2]
}

###################################################################
# Create satellite ROKS cluster
###################################################################
module "satellite-cluster" {
  source  = "terraform-ibm-modules/satellite/ibm//modules/cluster"
  version = "1.1.9"

  create_cluster             = var.create_cluster
  cluster                    = var.cluster
  zones                      = local.azs
  location                   = module.satellite-location.location_id
  resource_group             = var.resource_group
  kube_version               = var.kube_version
  worker_count               = var.worker_count
  host_labels                = var.cluster_host_labels
  tags                       = var.tags
  default_worker_pool_labels = var.default_worker_pool_labels
  create_timeout             = var.create_timeout
  update_timeout             = var.update_timeout
  delete_timeout             = var.delete_timeout

  depends_on = [module.satellite-assign-host]
}

###################################################################
# Create worker pool on existing ROKS cluster
###################################################################
module "satellite-cluster-worker-pool" {
  source  = "terraform-ibm-modules/satellite/ibm//modules/configure-cluster-worker-pool"
  version = "1.1.9"

  create_cluster_worker_pool = var.create_cluster_worker_pool
  worker_pool_name           = var.worker_pool_name
  cluster                    = var.cluster
  zones                      = local.azs
  resource_group             = var.resource_group
  kube_version               = var.kube_version
  worker_count               = var.worker_count
  host_labels                = var.worker_pool_host_labels
  create_timeout             = var.create_timeout
  delete_timeout             = var.delete_timeout

  depends_on = [module.satellite-cluster]
}