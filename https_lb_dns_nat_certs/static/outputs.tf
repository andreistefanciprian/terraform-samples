
# Resource attributes to be exported and be used by other terraform remote states

output "subnet-us" {
  value = "${google_compute_subnetwork.subnet-us.self_link}"
}

output "subnet-eu" {
  value = "${google_compute_subnetwork.subnet-eu.self_link}"
}

output "lb_global_address" {
  value = "${google_compute_global_address.lb_global_address.address}"
}
