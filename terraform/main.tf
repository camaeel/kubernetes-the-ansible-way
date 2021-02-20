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

resource "aws_resourcegroups_group" "kubernetes-the-ansible-way" {
  name = "kubernetes-the-ansible-way"

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::AllSupported"
  ],
  "TagFilters": [
    {
      "Key": "project",
      "Values": ["kubernetes-the-ansible-way"]
    }
  ]
}
JSON
  }
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
  vpc_security_group_ids = [ 
    aws_security_group.k8s-node-sg.id, 
    aws_security_group.k8s-controlplane-node-sg.id
  ]

  key_name = local.ssh_key_name

  tags = merge(
    var.additional_tags,
    {
      Name = "controlplane-${count.index}"
      ansible-group = "controlplane"
      index = count.index
    },
  )
}

resource "aws_instance" "worker" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.worker_node_size
  count         = var.worker_nodes_number
  subnet_id = element(module.network.public_subnets, count.index).id
  vpc_security_group_ids = [ 
    aws_security_group.k8s-node-sg.id 
  ]

  key_name = local.ssh_key_name

  tags = merge(
    var.additional_tags,
    {
      Name = "worker-${count.index}"
      ansible-group = "workers"
      index = count.index
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
    description = "ICMP ping from internet"
    protocol    = "icmp"
    from_port   = -1
    to_port     = -1
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
  description = "Allow access to controlplane k8s node from loadbalancer host"
  vpc_id      = module.network.vpc.id

  ingress {
    description = "kube-apiserver"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    security_groups = [aws_security_group.load-balancer-sg.id]
  }

  tags = merge(
    var.additional_tags,
    {
      Name = "k8s-controlplane-node-sg"
    },
  )
}

resource "aws_security_group" "load-balancer-sg" {
  name        = "load-balancer-sg"
  description = "Allow access to loadbalancer from internet"
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
      Name = "load-balancer-sg"
    },
  )
}

# simple load balancer host

resource "aws_instance" "loadbalancer" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.loadbalancer_node_size
  subnet_id = module.network.public_subnets[0].id
  vpc_security_group_ids = [ 
    aws_security_group.k8s-node-sg.id, 
    aws_security_group.load-balancer-sg.id
  ]

  key_name = local.ssh_key_name

  tags = merge(
    var.additional_tags,
    {
      Name = "loadbalancer"
      ansible-group = "loadbalancers"
    },
  )
}
