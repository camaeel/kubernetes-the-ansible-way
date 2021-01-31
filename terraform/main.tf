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
  security_groups = [ 
    aws_security_group.k8s-node-sg.id, 
    aws_security_group.k8s-controlplane-node-sg.id
  ]

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
  security_groups = [ 
    aws_security_group.k8s-node-sg.id 
  ]

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

resource "aws_security_group" "k8s-node-sg" {
  name        = "k8s-node-sg"
  description = "Allow access to generic k8s node"
  vpc_id      = module.network.vpc.id

  ingress {
    description = "SSH from internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP from internet"
    protocol    = "icmp"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Any traffic from the same SG"
    from_port   = 0
    to_port     = 0    
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.additional_tags,
    {
      Name = "k8s-node-sg"
    },
  )
}

resource "aws_security_group" "k8s-controlplane-node-sg" {
  name        = "k8s-controlplane-node-sg"
  description = "Allow access to controlplane k8s node"
  vpc_id      = module.network.vpc.id

  ingress {
    description = "kube-apiserver"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.additional_tags,
    {
      Name = "k8s-controlplane-node-sg"
    },
  )
}


