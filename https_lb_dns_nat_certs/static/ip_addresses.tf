
# HTTPS LB public IP
resource "google_compute_global_address" "lb_global_address" {
  name = "${var.name}-global-staticip"
}