terragrunt_version_constraint = "= v0.29.10"
terraform_version_constraint  = ">= 1.0.0"

remote_state {
  backend = "s3"

  config = {
    encrypt        = true
    bucket         = "YOUR_TERRAFORM_STATE_BUCKET_NAME"
    region         = "YOUR_TERRAFORM_STATE_BUCKET_REGION"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    acl            = "bucket-owner-full-control"
    dynamodb_table = "YOUR_DYNAMODB_TABLE"
  }
}
