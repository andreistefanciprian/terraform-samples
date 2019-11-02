
# Cloud NAT US
resource "google_compute_router" "router" {
  name    = "${var.name}-router"
  network = google_compute_network.vpc_network.self_link
  region  = var.region

}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.name}-router-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}


# Cloud NAT EU
resource "google_compute_router" "router_eu" {
  name    = "${var.name}-router"
  network = google_compute_network.vpc_network.self_link
  region  = var.region_eu

}

resource "google_compute_router_nat" "nat_eu" {
  name                               = "${var.name}-router-nat"
  router                             = google_compute_router.router_eu.name
  region                             = var.region_eu
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}