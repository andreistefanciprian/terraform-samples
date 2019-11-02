//# IAP IAM
//resource "google_project_iam_member" "project" {
//  project = var.project
//  role    = "roles/iap.httpsResourceAccessor"
//  member  = "user:alice@gmail.com"
//}

//# Alow ingress access via IAP
//resource "google_compute_firewall" "allow_https_from_gcpiap" {
//  name          = "fwrule-ingress-allow-https-from-gcpiap"
//  network       = "${data.terraform_remote_state.network.outputs.main_network}"
//  priority      = "11200"
//  source_ranges = "${var.source_ranges_gcpiap}"
//  target_tags   = ["backend"]
//
//  allow {
//    protocol = "tcp"
//    ports    = ["443"]
//  }
//}

# Define Certificate
resource "google_compute_ssl_certificate" "app_cert" {
  name_prefix = "${var.name}-ssl-cert"
  description = "SSL Certificate for ${var.name}"
  private_key = "${file("include/certs/private.key")}"
  certificate = "${file("include/certs/certificate.crt")}"

  lifecycle {
    create_before_destroy = true
  }
}

# Create the HTTPS Global Load Balancer
resource "google_compute_target_https_proxy" "app" {
  name             = "${var.name}-https-proxy"
  url_map          = "${google_compute_url_map.app.self_link}"
  ssl_certificates = ["${google_compute_ssl_certificate.app_cert.self_link}"]
}

resource "google_compute_global_forwarding_rule" "app" {
  name = "${var.name}-https-forwarding-rule"
  ip_address = data.terraform_remote_state.static.outputs.lb_global_address
  port_range = "443"
  target     = "${google_compute_target_https_proxy.app.self_link}"
}

resource "google_compute_url_map" "app" {
  name            = "${var.name}-proxy-url-map"
  default_service = "${google_compute_backend_service.app.self_link}"

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = "${google_compute_backend_service.app.self_link}"
  }
}

# Create LB Backend
resource "google_compute_backend_service" "app" {
  name        = "${var.name}-backend-service"
  port_name   = "https"
  protocol    = "HTTPS"
  timeout_sec = "30"
  enable_cdn  = "false"

  backend {
    group = "${google_compute_instance_group_manager.default_us.instance_group}"
    //    group = "${google_compute_instance_group_manager.appserver.self_link}"
  }

  backend {
  group = "${google_compute_instance_group_manager.default_eu.instance_group}"
}
  //  iap {
  //    oauth2_client_id = "${var.backend_oauth_client_id}"
  //    oauth2_client_secret = "${var.backend_oauth_client_password}"
  //  }

  health_checks = ["${google_compute_https_health_check.app.self_link}"]

  #security_policy = "${google_compute_security_policy.cloudarmor_policy.self_link}"
}

# Create LB Health Check
resource "google_compute_https_health_check" "app" {
  name                = "${var.name}-https-health-check"
  check_interval_sec  = 10
  timeout_sec         = 10
  healthy_threshold   = 2
  unhealthy_threshold = 2
  request_path        = "/status"
}