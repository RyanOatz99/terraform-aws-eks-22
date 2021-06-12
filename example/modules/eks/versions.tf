terraform {
  required_version = ">= 0.14.10"

  backend "s3" {}

  required_providers {
    aws        = "= 3.44.0"
    local      = "= 2.1.0"
    null       = "= 3.1.0"
    template   = "= 2.2.0"
    random     = "= 3.1.0"
    kubernetes = "= 2.3.1"
  }
}

provider "aws" {
  region = var.region
}
