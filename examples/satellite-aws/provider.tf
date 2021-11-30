#####################################################
# IBM Cloud Satellite -  AWS Example
# Copyright 2021 IBM
#####################################################

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
