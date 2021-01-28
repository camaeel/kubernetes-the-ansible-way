variable "vpc_cidr" {
  type = string
}

variable "subnet_mask_length" {
  type = number
}

variable "additional_tags" {
  default     = {"project": "kubernetes-the-ansible-way"}
  description = "Additional resource tags"
  type        = map(string)
}

variable "aws_zones" {
  type = list(string)
  description = "AWS availability zones"
}
