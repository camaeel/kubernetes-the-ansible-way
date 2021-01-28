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

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = [ var.node_ami_name ]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [var.node_ami_owner] # Canonical
}

locals {
  ssh_key_name = "kubernetes-ansible-way-ssh-key"
}


resource "aws_key_pair" "ssh_key" {
  key_name   = local.ssh_key_name
  public_key = var.public_key
  tags = merge(
    var.additional_tags,
    {
      Name = local.ssh_key_name
    },
  )
}

resource "aws_instance" "controlplane" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.controlplane_node_size
  count         = var.controlplane_nodes_number
  subnet_id = element(module.network.public_subnets, count.index).id

  key_name = local.ssh_key_name

  tags = merge(
    var.additional_tags,
    {
      Name = "controlplane-${count.index}"
      Role = "controlplane"
    },
  )
}

resource "aws_instance" "worker" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.worker_node_size
  count         = var.worker_nodes_number
  subnet_id = element(module.network.public_subnets, count.index).id

  key_name = local.ssh_key_name

  tags = merge(
    var.additional_tags,
    {
      Name = "worker-${count.index}"
      Role = "worker"
    },
  )
}

# TODO: security groups
