//
//# HTTPS LB public IP
//resource "google_compute_address" "default" {
//  name   = "${var.name}-lb-address"
//  region = var.region
//}

# HTTPS LB global public IP
resource "google_compute_global_address" "default" {
  name = "${var.name}-lb-address"
}