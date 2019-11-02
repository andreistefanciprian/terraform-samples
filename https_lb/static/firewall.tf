
# Create a firewall rule to allow HTTP, HTTPS, SSH, RDP and ICMP traffic on vpc network
resource "google_compute_firewall" "fw_allow_https_ssh_rdp_icmp" {
  name    = "${var.name}-allow-http-ssh-rdp-icmp"
  network = google_compute_network.vpc_network.self_link

  target_tags = ["backend"]
  source_ranges = ["0.0.0.0/0"]

//  enable_logging = true

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }
  allow {
    protocol = "icmp"
  }
}
