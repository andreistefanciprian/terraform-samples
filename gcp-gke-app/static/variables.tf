
# Define variables

variable "name" {
  description = "This name would be used to construct the names of the resources in this project."
  type        = string
  default     = "myapp"
}

variable "project" {
  description = "The project to deploy to."
  type        = string
  default     = "aerial-utility-246511"
}

variable "region" {
  type    = string
  default = "europe-west1"
}

variable "domain_name" {
  description = "DNS domain name."
  type        = string
  default     = "devopsnation.co.uk"
}

variable "secrets_bucket" {
  description = "Bucket where secrets are being stored."
  type        = string
  default     = "secrets-app"
}

//# Source IP ranges for health checks probes
//variable "source_ranges_health_check_probes" {
//  type    = "list"
//  default = ["35.191.0.0/16", "130.211.0.0/22"]
//}