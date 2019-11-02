
# Notes: To use attributes from previous layer, they must be in the output.tf file of the previous layer

data "terraform_remote_state" "static" {
  backend = "gcs"
  config = {
    bucket = "secrets-terraform"
    prefix = "terraform-static-state"
  }
}

