
# Resource attributes to be exported and be used by other terraform remote states
output "main_network" {
  value = "${google_compute_network.vpc_network.self_link}"
}

output "subnet-us" {
  value = "${google_compute_subnetwork.subnet-us.self_link}"
}

output "subnet-eu" {
  value = "${google_compute_subnetwork.subnet-eu.self_link}"
}

output "lb_global_address" {
  value = "${google_compute_global_address.lb_global_address.address}"
}
