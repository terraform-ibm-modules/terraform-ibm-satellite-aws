# satellite-aws

This example cover end-to-end functionality of IBM cloud satellite by creating satellite location on specified region.
It will provision satellite location and create 6 EC2 host and assign 3 host to control plane, and provision ROKS satellite cluster and auto assign 3 host to cluster,
Configure cluster worker pool to an existing ROKS satellite cluster.

## Compatibility

This module is meant for use with Terraform 0.13 or later.

## Requirements

### Terraform plugins

- [Terraform](https://www.terraform.io/downloads.html) 0.13 or later.
- [terraform-provider-ibm](https://github.com/IBM-Cloud/terraform-provider-ibm)

## Install

### Terraform

Be sure you have the correct Terraform version ( 0.13 or later), you can choose the binary here:
- https://releases.hashicorp.com/terraform/

### Terraform provider plugins

Be sure you have the compiled plugins on $HOME/.terraform.d/plugins/

- [terraform-provider-ibm](https://github.com/IBM-Cloud/terraform-provider-ibm)

## Usage

```
terraform init
```
```
terraform plan
```
```
terraform apply
```
```
terraform destroy
```

## Example Usage
``` hcl
provider "ibm" {
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

module "satellite-aws" {
  source  = "terraform-ibm-modules/satellite-aws/ibm"
  version = "1.0.0"

  ibmcloud_api_key           = var.ibmcloud_api_key   #pragma: allowlist secret
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
```

## Note

* `satellite-location` module creates new location or use existing location ID/name to process. If user pass the location which is already exist,   satellite-location module will error out and exit the module. In such cases user has to set `is_location_exist` value to true. So that module will use existing location for processing.
* `satellite-location` module download attach host script to the $HOME directory and appends respective permissions to the script.
* `satellite-location` module will update the attach host script and will be used in the `user_data` attribute of EC2 module.


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name                                  | Description                                                       | Type     | Default | Required |
|---------------------------------------|-------------------------------------------------------------------|----------|---------|----------|
| ibmcloud_api_key                      | IBM Cloud API key                                                 | string   | n/a     | yes      |
| aws_access_key                        | AWS access key                                                    | string   | n/a     | yes      |
| aws_secret_key                        | AWS secret key                                                    | string   | n/a     | yes      |
| aws_region                            | AWS cloud region                                                  | string   | us-east-1  | yes   |
| resource_group                        | Resource Group Name that has to be targeted.                      | string   | n/a     | yes      |
| location                              | Name of the Location that has to be created                       | string   | n/a     | satellite-ibm  |
| is_location_exist                     | Determines if the location has to be created or not               | bool     | false   | no       |
| managed_from                          | The IBM Cloud region to manage your Satellite location from.      | string   | wdc     | no      |
| location_zones                        | Allocate your hosts across three zones for higher availablity     | list     | []     | no  |
| host_labels                           | Add labels to attach host script                                  | list     | [env:prod]  | no   |
| location_bucket                       | COS bucket name                                                   | string   | n/a     | no       |
| host_count                            | The total number of host to create for control plane. host_count value should always be in multiples of 3, such as 3, 6, 9, or 12 hosts | number | 3 |  yes |
| addl_host_count                       | The total number of additional host                               | number   | 3       | no       |
| host_provider                         | The cloud provider of host/vms.                                   | string   | ibm     | no       |
| resource_prefix                       | Prefix to the Names of all VSI Resources                          | string   | satellite-aws | no|
| public_key                            | Public SSH key used to provision Host/VSI                         | string   | n/a     | no       |
| location_profile                      | Profile information of location hosts                             | string   | m5d.xlarge| no     |
| cluster_profile                       | Profile information of cluster hosts                              | string   | m5d.xlarge| no     |
| create_cluster                        | Create cluster                                                    | bool     | true    | no       |
| cluster                               | Name of the ROKS Cluster that has to be created                   | string   | n/a     | yes      |
| cluster_zones                         | Allocate your hosts across these three zones                      | set      | n/a     | yes      |
| kube_version                          | Kuber version                                                     | string   | 4.7_openshift | no |
| default_wp_labels                     | Labels on the default worker pool                                 | map      | n/a     | no       |
| workerpool_labels                     | Labels on the worker pool                                         | map      | n/a     | no       |
| cluster_tags                          | List of tags for the cluster resource                             | list     | n/a     | no       |
| create_cluster_worker_pool            | Create Cluster worker pool                                        | bool     | false   | no       |
| worker_pool_name                      | Worker pool name                                                  | string   | satellite-worker-pool  | no |
| workerpool_labels                     | Labels on the worker pool                                         | map      | n/a     | no       |
| create_timeout                        | Timeout duration for creation                                     | string   | n/a     | no       |
| update_timeout                        | Timeout duration for updation                                     | string   | n/a     | no       |
| delete_timeout                        | Timeout duration for deletion                                     | string   | n/a     | no       |


## Outputs

| Name                      | Description                           |
|---------------------------|---------------------------------------|
| location_id               | Location id                           |
| location_zones            | Location zones                        |
| host_script               | Host registartion script content      |
| host_ids                  | Assigned host id's                    |
| floating_ip_ids           | Floating IP id's                      |
| floating_ip_addresses     | Floating IP Addresses                 |
| vpc_id                    | VPC id                                |
| vpc_arn                   | VPC ARN                               |
| default_security_group_id | Security group id                     |
| private_subnets           | private Subnets id's                  |
| public_subnets            | public Subnets id's                   |
| location-ec2-private_dns  | location control plane host addresses |
| cluster-ec2-private_dns   | cluster host addresses                |
| cluster_id                | Cluster id                            |
| cluster_worker_pool_id    | Cluster worker pool id                |
| worker_pool_worker_count  | worker count deatails                 |
| worker_pool_zones         | workerpool zones                      |