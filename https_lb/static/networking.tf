
# Create the vpc network
resource "google_compute_network" "vpc_network" {
  name                    = "${var.name}-network"
  auto_create_subnetworks = false
}

# Create us subnetwork
resource "google_compute_subnetwork" "subnet-us" {
  name          = "${var.name}-network-us"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.self_link
  ip_cidr_range = "172.16.11.0/24"
}

# Create eu subnetwork
resource "google_compute_subnetwork" "subnet-eu" {
  name          = "${var.name}-network-eu"
  region        = "europe-west1"
  network       = google_compute_network.vpc_network.self_link
  ip_cidr_range = "172.16.22.0/24"
}
