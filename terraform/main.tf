terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "network" {
  source        = "./network"
  vpc_cidr        = var.vpc_cidr
  additional_tags = var.additional_tags
  aws_zones       = var.aws_zones
  subnet_mask_length = var.subnet_mask_length
}
