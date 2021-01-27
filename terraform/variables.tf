variable "aws_region" {
  type = string
  description = "AWS region"
  default     = "eu-central-1"
}

variable "aws_zones" {
  type = string
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
