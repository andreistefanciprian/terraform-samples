
provider "google" {
  project = var.project
  region  = var.region
}

provider "google-beta" {
  project = var.project
  region  = var.region
}

terraform {
  backend "gcs" {
    bucket = "secrets-terraform"
    prefix = "gke-terraform-static-state"
  }
}