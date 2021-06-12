variable "region" {
  type    = string
  default = "us-east-1"
}

variable "cluster_name" {
  type    = string
  default = "dev"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "vpc_public_subnets" {
  type    = list(string)
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "eks_override_instance_types" {
  type    = list(string)
  default = ["t3.xlarge", "t3a.xlarge", "m5a.xlarge"]
}

variable "eks_spot_instance_pools" {
  type    = string
  default = "2"
}

variable "eks_asg_max_size" {
  type    = string
  default = "2"
}

variable "eks_asg_desired_capacity" {
  type    = string
  default = "2"
}

variable "eks_kubelet_extra_args" {
  type    = string
  default = "--node-labels=node.kubernetes.io/lifecycle=spot"
}
