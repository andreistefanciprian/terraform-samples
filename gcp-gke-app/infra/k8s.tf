
# k8s deployment
resource "kubernetes_deployment" "default" {
  metadata {
    name = var.name
    labels = {
      app = var.name
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = var.name
      }
    }

    template {
      metadata {
        labels = {
          app = var.name
        }
      }

      spec {
        container {
          image = "gcr.io/${var.project}/nodeapp"
          name  = var.name

          resources {
            limits {
              cpu    = "100m"
              memory = "100Mi"
            }
            requests {
              cpu    = "50m"
              memory = "50Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 8080

              http_header {
                name  = "X-Custom-Header"
                value = "Awesome"
              }
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
}

# k8s hpa
resource "kubernetes_horizontal_pod_autoscaler" "default" {
  metadata {
    name = var.name
  }
  spec {
    max_replicas                      = 6
    min_replicas                      = 2
    target_cpu_utilization_percentage = "50"

    scale_target_ref {
      api_version = "extensions/v1beta1"
      kind        = "Deployment"
      name        = var.name
    }
  }
  depends_on = [
    kubernetes_deployment.default,
  ]
}

# k8s service
resource "kubernetes_service" "default" {
  metadata {
    name = var.name
  }

  spec {
    selector = {
      app = var.name
    }

    //    session_affinity = "ClientIP"
    session_affinity = "None"

    port {
      protocol    = "TCP"
      port        = 80
      target_port = 8080
      node_port   = 30080
    }

    type             = "LoadBalancer"
    load_balancer_ip = data.terraform_remote_state.static.outputs.lb_ip
  }
}