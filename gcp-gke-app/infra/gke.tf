
data "google_client_config" "current" {}

data "google_container_engine_versions" "default" {
  location = var.region
}

resource "google_container_cluster" "default" {
  name               = "${var.name}-gke-cluster"
  location           = var.region
  initial_node_count = 1
  min_master_version = data.google_container_engine_versions.default.latest_master_version
  network = data.terraform_remote_state.static.outputs.main_network
  subnetwork = data.terraform_remote_state.static.outputs.subnet

  node_config {
    tags = ["gke-node"]
    disk_size_gb = "20"
  }

  // Use legacy ABAC until these issues are resolved:
  //   https://github.com/mcuadros/terraform-provider-helm/issues/56
  //   https://github.com/terraform-providers/terraform-provider-kubernetes/pull/73
  enable_legacy_abac = true

  // Wait for the GCE LB controller to cleanup the resources.
  provisioner "local-exec" {
    when    = destroy
    command = "sleep 90"
  }
}

