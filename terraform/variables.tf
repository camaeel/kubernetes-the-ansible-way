# Infra related variables
variable "aws_region" {
  type = string
  description = "AWS region"
  default     = "eu-north-1"
}

variable "aws_zones" {
  type = list(string)
  description = "AWS availability zones"
  default     = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
}
variable "additional_tags" {
  default     = {"project": "kubernetes-the-ansible-way"}
  description = "Additional resource tags"
  type        = map(string)
}

variable "loadbalancer_node_size" {
  type = string
  description = "K8s loadbalancer node size"
  default     = "t3.micro"
}

variable "controlplane_nodes_number" {
  type = number
  description = "K8s controlplane nodes number. It should always be odd number"
  default     = "3"
}
# TODO: add validation if number is odd

variable "controlplane_node_size" {
  type = string
  description = "K8s controlplane node size"
  default     = "t3.micro"
}

variable "worker_nodes_number" {
  type = number
  description = "K8s worker nodes number"
  default     = "2"
}

variable "worker_node_size" {
  type = string
  description = "K8s worker node size"
  default     = "t3.micro"
}

# networks
variable "vpc_cidr" {
  type = string
  description = "CIDR for nodes vpc"
  default = "10.10.0.0/16"
}

variable "subnet_mask_length" {
  type = number
  default = 24
  description = "VPC subnet bit mask"
}

variable "node_ami_name" {
  type = string
  default = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
  description = "Node AMI name"
}

variable "node_ami_owner" {
  type = string
  default = "099720109477"
  description = "Node AMI owner"
}

variable "public_key" {
  type = string
  description = "public key used to access EC2 instances"
}
