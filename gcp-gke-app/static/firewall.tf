
//# Create a firewall rule to allow HTTP, HTTPS, SSH, RDP and ICMP traffic on vpc network
//resource "google_compute_firewall" "fw_allow_https_ssh_rdp_icmp" {
//  name    = "${var.name}-allow-http-ssh-rdp-icmp"
//  network = google_compute_network.vpc_network.self_link
//
//  target_tags = ["gke-node"]
//  source_ranges = ["0.0.0.0/0"]
//
////  enable_logging = true
//
//  allow {
//    protocol = "tcp"
//    ports    = ["22", "80", "443"]
//  }
//  allow {
//    protocol = "icmp"
//  }
//}

# Create a firewall rule to allow NodePort access
resource "google_compute_firewall" "fw_allow_node_port_access" {
  name    = "${var.name}-allow-node-port-access"
  network = google_compute_network.vpc_network.self_link

  target_tags = ["gke-node"]
  source_ranges = ["0.0.0.0/0"]

//  enable_logging = true

  allow {
    protocol = "tcp"
    ports    = ["30000-32767"]
  }

}