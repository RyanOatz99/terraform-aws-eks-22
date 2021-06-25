data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

locals {
  cluster_name = "${var.cluster_name}-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "= 3.1.0"

  name                 = "${local.cluster_name}-vpc"
  cidr                 = var.vpc_cidr
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = var.vpc_public_subnets
  enable_dns_hostnames = true
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu-eks/k8s_1.20/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

module "eks" {
  source                    = "terraform-aws-modules/eks/aws"
  version                   = "= 17.1.0"
  cluster_name              = local.cluster_name
  cluster_version           = "1.20"
  subnets                   = module.vpc.public_subnets
  vpc_id                    = module.vpc.vpc_id
  cluster_service_ipv4_cidr = var.cluster_service_ipv4_cidr

  worker_groups_launch_template = [
    {
      name                    = "eks-spot"
      ami_id                  = data.aws_ami.ubuntu.id
      override_instance_types = var.eks_override_instance_types
      spot_instance_pools     = var.eks_spot_instance_pools
      asg_max_size            = var.eks_asg_max_size
      asg_desired_capacity    = var.eks_asg_desired_capacity
      kubelet_extra_args      = var.eks_kubelet_extra_args
      public_ip               = true

      additional_userdata     = templatefile("${path.module}/templates/user-data.tmpl", {
        additional_ssh_key    = var.additional_ssh_key,
        ssh_user              = var.ssh_user
      })

      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${local.cluster_name}"
          "propagate_at_launch" = "false"
          "value"               = "owned"
        }
      ]
    }
  ]

  workers_additional_policies = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/Cluster_Autoscaler_Policy"]

  depends_on = [
    aws_iam_policy.cluster-autoscaler-policy
  ]
}