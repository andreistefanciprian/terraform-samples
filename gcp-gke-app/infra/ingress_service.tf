resource "kubernetes_service" "default" {
  metadata {
//    namespace = kubernetes_namespace.staging.metadata.0.name
    name      = var.name
  }

  spec {
    selector = {
      app = var.name
    }

//    session_affinity = "ClientIP"
    session_affinity = "None"

    port {
      protocol    = "TCP"
      port        = 8080
      target_port = 8080
      node_port   = 30080
    }

    type             = "NodePort"
//    load_balancer_ip = data.terraform_remote_state.static.outputs.lb_ip
  }
}

# store certs as secrets
resource "kubernetes_secret" "tls" {
  metadata {
    name = "tls-secret"
  }

  data = {
    "tls.crt" = file("include/certs/certificate.crt")
    "tls.key" = file("include/certs/private.key")
  }

  type  = "kubernetes.io/tls"
}



# build Global HTTPS LB in GCP
resource "kubernetes_ingress" "default" {

  metadata {

    name = var.name
    // # ditch HTTP LB and use reserved IP
//    annotations {
//      "kubernetes.io/ingress.global-static-ip-name"   = "myapp-lb-address"
//      "kubernetes.io/ingress.allow-http" = "false"
//    }

  }

  spec {

    rule {
      host = var.domain_name
      http {
        path {
          backend {
            service_name = kubernetes_service.default.metadata.0.name
            service_port = 8080
          }

          path = "/*"
        }

      }
    }

    tls {
      secret_name = "tls-secret"
      hosts = [ var.domain_name, ]
    }
  }
}

# HTTPS LB public IP
resource "google_compute_global_address" "lb_global_address" {
  name = "global-staticip"
}