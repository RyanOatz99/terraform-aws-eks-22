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
  type        = list(string)
  description = "A list of override instance types for mixed instances policy"
  default     = ["t3.2xlarge", "t3a.2xlarge", "m5a.2xlarge"]
}

variable "eks_override_instance_types_gpu" {
  type        = list(string)
  description = "A list of override instance types for mixed instances policy"
  default     = ["g4dn.2xlarge"]
}

variable "eks_spot_instance_pools" {
  type        = string
  description = "Number of Spot pools per availability zone to allocate capacity. EC2 Auto Scaling selects the cheapest Spot pools and evenly allocates Spot capacity across the number of Spot pools that you specify."
  default     = "2"
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
  type        = string
  description = "This string is passed directly to kubelet if set. Useful for adding labels or taints."
  default     = "--node-labels=node.kubernetes.io/lifecycle=spot"
}

variable "eks_kubelet_extra_args_gpu" {
  type        = string
  description = "This string is passed directly to kubelet if set. Useful for adding labels or taints."
  default     = "--node-labels=node.kubernetes.io/lifecycle=spot --register-with-taints=nvidia.com/gpu=present:NoSchedule --node-labels=nvidia.com/gpu=present"
}

variable "bootstrap_extra_args" {
  type        = string
  description = "The latest versions of the AWS EKS-optimized AMI disable the docker bridge network by default. To enable it, add the bootstrap_extra_args parameter to your worker group template."
  default     = "--enable-docker-bridge true"
}

variable "cluster_service_ipv4_cidr" {
  type        = string
  description = "The IP address range from which cluster services will receive IP addresses. Manually configuring this range can help prevent conflicts between Kubernetes services and other networks peered or connected to your VPC."
  default     = "172.20.0.0/16"
}

variable "additional_ssh_key" {
  description = "Additional SSH public key to add to the instance."
  type        = string
  default     = null
}

variable "ssh_user" {
  description = "A user for instance ssh."
  type        = string
  default     = "ec2-user"
}