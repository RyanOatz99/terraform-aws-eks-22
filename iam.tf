resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9E99A48A9960B14926BB7F3B02E22DA2B0AB7280"]
  url             = module.eks.cluster_oidc_issuer_url

  depends_on = [
    module.eks
  ]
}

data "aws_iam_policy_document" "trust_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.cluster.url, "https://", "")}:sub"
      values   = [
        "system:serviceaccount:kube-system:cluster-autoscaler", 
        "system:serviceaccount:kube-system:external-dns"
      ]
    }

    principals {
      identifiers = ["${aws_iam_openid_connect_provider.cluster.arn}"]
      type        = "Federated"
    }
  }
}

# cluster-autoscaler

resource "aws_iam_policy" "cluster-autoscaler-policy" {
  name        = "Cluster_Autoscaler_Policy"
  description = "Cluster Autoscaler Policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeTags",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeLaunchTemplateVersions"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role" "cluster-autoscaler-role" {
  assume_role_policy = data.aws_iam_policy_document.trust_assume_role_policy.json
  name               = "${local.cluster_name}-cluster-autoscaler"

  depends_on = [
    aws_iam_openid_connect_provider.cluster
  ]
}

resource "aws_iam_role_policy_attachment" "cluster-autoscaler-role-attachment" {
  role       = aws_iam_role.cluster-autoscaler-role.name
  policy_arn = aws_iam_policy.cluster-autoscaler-policy.arn
}

# external-dns

resource "aws_iam_policy" "external-dns-policy" {
  name        = "External_Dns_Policy"
  description = "External-dns Policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role" "external-dns-role" {
  assume_role_policy = data.aws_iam_policy_document.trust_assume_role_policy.json
  name               = "${local.cluster_name}-external-dns"

  depends_on = [
    aws_iam_openid_connect_provider.cluster
  ]
}

resource "aws_iam_role_policy_attachment" "external-dns-role-attachment" {
  role       = aws_iam_role.external-dns-role.name
  policy_arn = aws_iam_policy.external-dns-policy.arn
}
