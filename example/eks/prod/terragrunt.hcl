include {
  path = find_in_parent_folders()
}

terraform {
  source = "../..//modules/eks"
}

locals { common_vars = yamldecode(file("values.yaml")) }

inputs = local.common_vars
