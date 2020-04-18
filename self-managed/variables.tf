variable "vpc_cidr_range" {
  type = string
}

variable "eks_cluster_name" {
  type    = string
  default = "main"
}

variable "private_subnets" {
  type = list(string)
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "kubernetes_version" {
  type    = string
  default = "1.15"
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

