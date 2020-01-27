

resource "google_container_cluster" "primary" {
  name     = "${var.name}-gke-cluster"
  location = var.zone_us

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count = 1

  network = data.terraform_remote_state.static.outputs.main_network
  subnetwork = data.terraform_remote_state.static.outputs.subnet-us

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

//resource "google_container_node_pool" "primary_preemptible_nodes" {
//  name       = "${var.name}-node-pool"
//  location   = var.region
//  cluster    = "${google_container_cluster.primary.name}"
//  node_count = 1
//
//  node_config {
//    preemptible  = true
//    machine_type = "n1-standard-1"
//    disk_size_gb = "50"
//
//    metadata = {
//      disable-legacy-endpoints = "true"
//    }
//
//    oauth_scopes = [
//      "https://www.googleapis.com/auth/logging.write",
//      "https://www.googleapis.com/auth/monitoring",
//    ]
//  }
//}