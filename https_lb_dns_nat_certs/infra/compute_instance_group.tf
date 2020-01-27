# Copy files to Bucket

resource "google_storage_bucket_object" "startup_script" {
  bucket  = var.secrets_bucket
  name    = "startup.sh"
  content = "${file("include/startup.sh")}"
}

resource "google_storage_bucket_object" "nginx_config" {
  bucket  = var.secrets_bucket
  name    = "nginx.conf"
  content = "${file("include/nginx.conf")}"
}

# US
resource "google_compute_instance_template" "default_us" {

  name_prefix = "${var.name}-instance-"
  description = "This template is used to create compute engine instances."

  instance_description = "Compute Engine running an HTTP server"
  machine_type         = var.machine_type
  can_ip_forward       = false

  tags = ["backend"]

  // Create a new boot disk from an image
  disk {
    source_image = var.os_image
    auto_delete  = true
    boot         = true
  }


  network_interface {
    subnetwork = data.terraform_remote_state.static.outputs.subnet-us
  }

  metadata = {
    //    startup-script-url = "gs://cloud-training/gcpnet/httplb/startup.sh"
    startup-script-url = "gs://${var.secrets_bucket}/startup.sh"
    domain-name        = var.domain_name
    secrets-bucket     = var.secrets_bucket
  }

  lifecycle {
    create_before_destroy = true
  }

  service_account {
    scopes = [
      "compute-ro",
      "logging-write",
      "monitoring-write",
      "storage-full",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/source.read_only",
    ]
  }

}


resource "google_compute_instance_group_manager" "default_us" {
  provider = google-beta
  name = "${var.name}-appserver-igm-us"

  base_instance_name = "${var.name}-app-us"

  version {
    name              = "default_us"
    instance_template  = "${google_compute_instance_template.default_us.self_link}"
  }

  zone               = var.zone_us

  named_port {
    name = "https"
    port = 443
  }

}

resource "google_compute_autoscaler" "default_us" {
  name   = "${var.name}-autoscaler-us"
  zone   = var.zone_us
  target = "${google_compute_instance_group_manager.default_us.self_link}"

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.8
    }
  }
}


# EU

resource "google_compute_instance_template" "default_eu" {

  name_prefix = "${var.name}-instance-eu-"
  description = "This template is used to create compute engine instances."

  instance_description = "Compute Engine running an HTTP server"
  machine_type         = var.machine_type
  can_ip_forward       = false

  tags = ["backend"]

  // Create a new boot disk from an image
  disk {
    source_image = var.os_image
    auto_delete  = true
    boot         = true
  }


  network_interface {
    subnetwork = data.terraform_remote_state.static.outputs.subnet-eu
  }

  metadata = {
    //    startup-script-url = "gs://cloud-training/gcpnet/httplb/startup.sh"
    startup-script-url = "gs://${var.secrets_bucket}/startup.sh"
    domain-name        = var.domain_name
    secrets-bucket     = var.secrets_bucket
  }

  lifecycle {
    create_before_destroy = true
  }

  service_account {
    scopes = [
      "compute-ro",
      "logging-write",
      "monitoring-write",
      "storage-full",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/source.read_only",
    ]
  }

}



resource "google_compute_instance_group_manager" "default_eu" {
  provider = google-beta
  name = "${var.name}-appserver-igm-eu"

  base_instance_name = "${var.name}-app-eu"

  zone               = var.zone_eu

  version {
    name              = "default_eu"
    instance_template  = "${google_compute_instance_template.default_eu.self_link}"
  }

  named_port {
    name = "https"
    port = 443
  }

}

resource "google_compute_autoscaler" "default_eu" {
  name   = "${var.name}-autoscaler-eu"
  zone   = var.zone_eu
  target = "${google_compute_instance_group_manager.default_eu.self_link}"

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.8
    }
  }
}