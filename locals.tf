#####################################################
# IBM Cloud Satellite -  AWS
# Copyright 2021 IBM
#####################################################

locals {
  azs = length(var.location_zones) == 3 ? var.location_zones : slice(data.aws_availability_zones.available.names, 0, 3)
}