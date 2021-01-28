# Backend variables
variable "backend_bucket_name" {
  type = string
  description = "TF state S3 bucket name"
}

variable "backend_bucket_key" {
  type = string
  description = "TF state path in S3 bucket"
  default     = "kubernetes-the-ansible-way"
}

variable "backend_aws_region" {
  type = string
  description = "AWS S3 backend region"
  default     = "eu-central-1"
}

# Infra related variables
variable "aws_region" {
  type = string
  description = "AWS region"
  default     = "eu-central-1"
}

variable "aws_zones" {
  type = list(string)
  description = "AWS availability zones"
  default     = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
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
  default     = "t2.micro"
}

variable "worker_nodes_number" {
  type = number
  description = "K8s worker nodes number"
  default     = "2"
}

variable "worker_node_size" {
  type = string
  description = "K8s worker node size"
  default     = "t2.micro"
}
