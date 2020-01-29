
# Create the vpc network
resource "google_compute_network" "vpc_network" {
  name                    = "${var.name}-network"
  auto_create_subnetworks = false
}
// Pick subnets in the following RFC1918 IP space
//     10.0.0.0        -   10.255.255.255  (10/8 prefix)
//     172.16.0.0      -   172.31.255.255  (172.16/12 prefix)
//     192.168.0.0     -   192.168.255.255 (192.168/16 prefix)

# Create subnetwork
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.name}-network-eu"
  region        = var.region
  network       = google_compute_network.vpc_network.self_link
  ip_cidr_range = "172.17.0.0/24"
}
