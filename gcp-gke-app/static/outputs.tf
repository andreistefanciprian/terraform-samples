
# Resource attributes to be exported and be used by other terraform remote states
output "main_network" {
  value = google_compute_network.vpc_network.self_link
}

output "subnet" {
  value = google_compute_subnetwork.subnet.self_link
}

output "lb_ip" {
  value = google_compute_address.default.address
}
